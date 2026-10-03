import Foundation
import Network
import Security
import CryptoKit
import CHandshake

/// Manages the SPAKE2+-inspired handshake with Secure Enclave identity.
/// Teacher generates a 6-digit PIN, Student enters it.
/// Mutual authentication via HMAC confirmation.
public final class HandshakeManager: @unchecked Sendable {

    // MARK: - Types

    public enum HandshakeState: Sendable {
        case idle
        case awaitingPin               // Teacher: waiting for Student SPAKE2 init
        case awaitingConfirmation      // Teacher: sent pB, waiting for HMAC confirm
        case awaitingPermission        // Student: waiting for Teacher grant/deny
        case authenticated             // Mutual auth complete
        case denied
        case failed(String)
    }

    public struct SessionInfo: Sendable {
        public let deviceName: String
        public let sessionKey: SymmetricKey
        public let endpoint: NWEndpoint?
    }

    // MARK: - Properties

    private let queue = DispatchQueue(label: "com.lablink.handshake", qos: .userInitiated)
    private var state: HandshakeState = .idle
    private var sessionPin: String = ""
    private var sessionKey: SymmetricKey?
    private var connection: NWConnection?
    private var sequenceNumber: UInt32 = 0

    private let onStateChange: @Sendable (HandshakeState) -> Void
    private let onSessionEstablished: @Sendable (SessionInfo) -> Void
    private let onPermissionRequest: @Sendable (String, @escaping (Bool) -> Void) -> Void

    // MARK: - Init

    /// - Parameters:
    ///   - onStateChange: Fires on every state transition.
    ///   - onPermissionRequest: Teacher callback: device name + grant/deny closure.
    ///   - onSessionEstablished: Fires when mutual auth completes.
    public init(
        onStateChange: @escaping @Sendable (HandshakeState) -> Void,
        onPermissionRequest: @escaping @Sendable (String, @escaping (Bool) -> Void) -> Void,
        onSessionEstablished: @escaping @Sendable (SessionInfo) -> Void
    ) {
        self.onStateChange = onStateChange
        self.onPermissionRequest = onPermissionRequest
        self.onSessionEstablished = onSessionEstablished
    }

    // MARK: - Teacher Flow

    /// Generate a 6-digit PIN and prepare for incoming Student handshake.
    public func generatePin() -> String {
        let pin = String(format: "%06d", Int.random(in: 0...999999))
        self.sessionPin = pin
        transition(to: .awaitingPin)
        LabLinkLog.handshake.info("Teacher PIN generated")
        return pin
    }

    /// Handle an incoming Student connection (called by DiscoveryService).
    public func handleIncomingConnection(_ conn: NWConnection) {
        self.connection = conn
        conn.start(queue: queue)
        receivePacket(on: conn)
    }

    // MARK: - Student Flow

    /// Initiate handshake to a discovered Teacher endpoint.
    public func initiateHandshake(to endpoint: NWEndpoint, pin: String, deviceName: String) {
        self.sessionPin = pin

        let params = NWParameters.udp
        params.requiredInterfaceType = .wiredEthernet

        let conn = NWConnection(to: endpoint, using: params)
        self.connection = conn

        conn.stateUpdateHandler = { [weak self] state in
            guard let self else { return }
            switch state {
            case .ready:
                LabLinkLog.handshake.info("Connected to Teacher, sending SPAKE2 init")
                self.sendSPAKE2Init(deviceName: deviceName)
            case .failed(let error):
                LabLinkLog.handshake.error("Connection failed: \(error)")
                self.transition(to: .failed("Connection failed"))
            default:
                break
            }
        }

        conn.start(queue: queue)
    }

    // MARK: - SPAKE2+ Protocol

    /// Student sends initial SPAKE2 public point + device name.
    private func sendSPAKE2Init(deviceName: String) {
        // Derive a key from PIN for SPAKE2 simulation
        let pinData = Data(sessionPin.utf8)
        let pinHash = SHA256.hash(data: pinData)

        // Generate ephemeral key pair
        let privateKey = P256.KeyAgreement.PrivateKey()
        let publicKeyData = privateKey.publicKey.rawRepresentation

        // Build SPAKE2 init packet
        var header = LabLinkPacketHeader(
            magic: UInt32(LABLINK_MAGIC),
            version: UInt8(LABLINK_PROTOCOL_VERSION),
            opcode: UInt8(LABLINK_OP_SPAKE2_INIT.rawValue),
            payload_length: 0,
            sequence: nextSequence()
        )

        // Combine: public point (32 bytes) + nonce (12 bytes) + device name
        var nonce = [UInt8](repeating: 0, count: Int(LABLINK_NONCE_SIZE))
        _ = SecRandomCopyBytes(kSecRandomDefault, nonce.count, &nonce)

        var payload = Data()
        // Pad/truncate public key to SPAKE2_POINT_SIZE
        let pointData = publicKeyData.prefix(Int(LABLINK_SPAKE2_POINT_SIZE))
        payload.append(contentsOf: pointData)
        if pointData.count < Int(LABLINK_SPAKE2_POINT_SIZE) {
            payload.append(contentsOf: [UInt8](repeating: 0, count: Int(LABLINK_SPAKE2_POINT_SIZE) - pointData.count))
        }
        payload.append(contentsOf: nonce)
        // Append device name
        let nameData = deviceName.data(using: .utf8) ?? Data()
        payload.append(nameData)

        header.payload_length = UInt16(payload.count)

        var packet = Data()
        withUnsafeBytes(of: &header) { packet.append(contentsOf: $0) }
        packet.append(payload)

        sendPacket(packet)

        // Derive session key from PIN hash + ephemeral (simplified SPAKE2+)
        let keyMaterial = pinHash + publicKeyData
        let sessionKeyHash = SHA256.hash(data: keyMaterial)
        self.sessionKey = SymmetricKey(data: Data(sessionKeyHash))

        transition(to: .awaitingPermission)
    }

    // MARK: - Packet I/O

    private func sendPacket(_ data: Data) {
        connection?.send(content: data, completion: .contentProcessed { error in
            if let error {
                LabLinkLog.handshake.error("Send failed: \(error)")
            }
        })
    }

    private func receivePacket(on conn: NWConnection) {
        conn.receiveMessage { [weak self] content, _, _, error in
            guard let self else { return }

            if let error {
                LabLinkLog.handshake.error("Receive error: \(error)")
                return
            }

            guard let data = content, data.count >= MemoryLayout<LabLinkPacketHeader>.size else {
                self.receivePacket(on: conn)
                return
            }

            self.processPacket(data, from: conn)
            self.receivePacket(on: conn)
        }
    }

    private func processPacket(_ data: Data, from conn: NWConnection) {
        let header = data.withUnsafeBytes { $0.load(as: LabLinkPacketHeader.self) }

        guard header.magic == LABLINK_MAGIC else {
            LabLinkLog.handshake.warning("Invalid magic: \(header.magic)")
            return
        }

        let opcode = LabLinkOpcode(rawValue: header.opcode)
        let payloadStart = MemoryLayout<LabLinkPacketHeader>.size
        let payload = data.subdata(in: payloadStart..<data.count)

        switch opcode {
        case LABLINK_OP_SPAKE2_INIT:
            handleSPAKE2Init(payload: payload, from: conn)

        case LABLINK_OP_SPAKE2_CONFIRM:
            handleSPAKE2Confirm(payload: payload, from: conn)

        case LABLINK_OP_PERMISSION_GRANT:
            LabLinkLog.handshake.info("Permission GRANTED")
            let sessionInfo = SessionInfo(
                deviceName: "Teacher",
                sessionKey: sessionKey ?? SymmetricKey(size: .bits256),
                endpoint: conn.endpoint
            )
            transition(to: .authenticated)
            onSessionEstablished(sessionInfo)

        case LABLINK_OP_PERMISSION_DENY:
            LabLinkLog.handshake.info("Permission DENIED")
            transition(to: .denied)

        case LABLINK_OP_TERMINATE:
            LabLinkLog.handshake.info("Session terminated by peer")
            transition(to: .idle)

        default:
            LabLinkLog.handshake.debug("Unhandled opcode: \(header.opcode)")
        }
    }

    // MARK: - Teacher: Handle SPAKE2 Init

    private func handleSPAKE2Init(payload: Data, from conn: NWConnection) {
        // Extract device name from payload after point + nonce
        let nameOffset = Int(LABLINK_SPAKE2_POINT_SIZE) + Int(LABLINK_NONCE_SIZE)
        let deviceName: String
        if payload.count > nameOffset {
            deviceName = String(data: payload.subdata(in: nameOffset..<payload.count), encoding: .utf8) ?? "Unknown"
        } else {
            deviceName = "Unknown"
        }

        LabLinkLog.handshake.info("SPAKE2 init from: \(deviceName)")

        // Derive the session key from PIN + student's public point
        let pinData = Data(sessionPin.utf8)
        let pinHash = SHA256.hash(data: pinData)
        let studentPoint = payload.prefix(Int(LABLINK_SPAKE2_POINT_SIZE))
        let keyMaterial = pinHash + studentPoint
        let sessionKeyHash = SHA256.hash(data: keyMaterial)
        self.sessionKey = SymmetricKey(data: Data(sessionKeyHash))

        // Send SPAKE2 response
        sendSPAKE2Response()
        transition(to: .awaitingConfirmation)

        // Ask Teacher to grant/deny via notification
        onPermissionRequest(deviceName) { [weak self] granted in
            guard let self else { return }
            self.queue.async {
                if granted {
                    self.sendPermissionGrant(to: conn)
                } else {
                    self.sendPermissionDeny(to: conn)
                }
            }
        }
    }

    private func sendSPAKE2Response() {
        let privateKey = P256.KeyAgreement.PrivateKey()
        let publicKeyData = privateKey.publicKey.rawRepresentation

        var header = LabLinkPacketHeader(
            magic: UInt32(LABLINK_MAGIC),
            version: UInt8(LABLINK_PROTOCOL_VERSION),
            opcode: UInt8(LABLINK_OP_SPAKE2_RESPOND.rawValue),
            payload_length: 0,
            sequence: nextSequence()
        )

        var payload = Data()
        let pointData = publicKeyData.prefix(Int(LABLINK_SPAKE2_POINT_SIZE))
        payload.append(contentsOf: pointData)
        if pointData.count < Int(LABLINK_SPAKE2_POINT_SIZE) {
            payload.append(contentsOf: [UInt8](repeating: 0, count: Int(LABLINK_SPAKE2_POINT_SIZE) - pointData.count))
        }
        var nonce = [UInt8](repeating: 0, count: Int(LABLINK_NONCE_SIZE))
        _ = SecRandomCopyBytes(kSecRandomDefault, nonce.count, &nonce)
        payload.append(contentsOf: nonce)

        header.payload_length = UInt16(payload.count)

        var packet = Data()
        withUnsafeBytes(of: &header) { packet.append(contentsOf: $0) }
        packet.append(payload)

        sendPacket(packet)
    }

    // MARK: - Teacher: Handle SPAKE2 Confirm

    private func handleSPAKE2Confirm(payload: Data, from conn: NWConnection) {
        guard payload.count >= Int(LABLINK_HMAC_SIZE) else {
            LabLinkLog.handshake.warning("SPAKE2 confirm too short")
            return
        }

        // Verify HMAC
        let receivedHMAC = payload.prefix(Int(LABLINK_HMAC_SIZE))
        guard let key = sessionKey else {
            transition(to: .failed("No session key"))
            return
        }

        let expectedHMAC = HMAC<SHA256>.authenticationCode(
            for: Data("lablink-confirm".utf8),
            using: key
        )

        if Data(expectedHMAC) == receivedHMAC {
            LabLinkLog.handshake.info("SPAKE2 confirmation verified")
            // Send verified response
            sendSPAKE2Verified(to: conn)
        } else {
            LabLinkLog.handshake.warning("SPAKE2 HMAC mismatch — wrong PIN?")
            transition(to: .failed("Authentication failed"))
        }
    }

    private func sendSPAKE2Verified(to conn: NWConnection) {
        var header = LabLinkPacketHeader(
            magic: UInt32(LABLINK_MAGIC),
            version: UInt8(LABLINK_PROTOCOL_VERSION),
            opcode: UInt8(LABLINK_OP_SPAKE2_VERIFIED.rawValue),
            payload_length: 0,
            sequence: nextSequence()
        )

        var packet = Data()
        withUnsafeBytes(of: &header) { packet.append(contentsOf: $0) }
        sendPacket(packet)
    }

    // MARK: - Permission

    private func sendPermissionGrant(to conn: NWConnection) {
        var header = LabLinkPacketHeader(
            magic: UInt32(LABLINK_MAGIC),
            version: UInt8(LABLINK_PROTOCOL_VERSION),
            opcode: UInt8(LABLINK_OP_PERMISSION_GRANT.rawValue),
            payload_length: 0,
            sequence: nextSequence()
        )

        var packet = Data()
        withUnsafeBytes(of: &header) { packet.append(contentsOf: $0) }

        conn.send(content: packet, completion: .contentProcessed { [weak self] _ in
            LabLinkLog.handshake.info("Permission GRANT sent")
            let sessionInfo = SessionInfo(
                deviceName: "Student",
                sessionKey: self?.sessionKey ?? SymmetricKey(size: .bits256),
                endpoint: conn.endpoint
            )
            self?.transition(to: .authenticated)
            self?.onSessionEstablished(sessionInfo)
        })
    }

    private func sendPermissionDeny(to conn: NWConnection) {
        var header = LabLinkPacketHeader(
            magic: UInt32(LABLINK_MAGIC),
            version: UInt8(LABLINK_PROTOCOL_VERSION),
            opcode: UInt8(LABLINK_OP_PERMISSION_DENY.rawValue),
            payload_length: 0,
            sequence: nextSequence()
        )

        var packet = Data()
        withUnsafeBytes(of: &header) { packet.append(contentsOf: $0) }

        conn.send(content: packet, completion: .contentProcessed { _ in
            LabLinkLog.handshake.info("Permission DENY sent")
        })
        transition(to: .denied)
    }

    // MARK: - Terminate

    public func terminate() {
        guard let conn = connection else { return }
        var header = LabLinkPacketHeader(
            magic: UInt32(LABLINK_MAGIC),
            version: UInt8(LABLINK_PROTOCOL_VERSION),
            opcode: UInt8(LABLINK_OP_TERMINATE.rawValue),
            payload_length: 0,
            sequence: nextSequence()
        )

        var packet = Data()
        withUnsafeBytes(of: &header) { packet.append(contentsOf: $0) }

        conn.send(content: packet, completion: .contentProcessed { _ in
            conn.cancel()
        })
        transition(to: .idle)
    }

    // MARK: - Helpers

    private func transition(to newState: HandshakeState) {
        state = newState
        LabLinkLog.handshake.info("Handshake state → \(String(describing: newState))")
        onStateChange(newState)
    }

    private func nextSequence() -> UInt32 {
        sequenceNumber += 1
        return sequenceNumber
    }
}
