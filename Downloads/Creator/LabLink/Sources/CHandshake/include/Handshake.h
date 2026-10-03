/**
 * Handshake.h
 * LabLinkD — Cross-Platform Protocol Header
 *
 * Defines the wire protocol for LabLink handshake and streaming.
 * Designed for Phase 2 Windows/Linux compatibility.
 */

#ifndef LABLINK_HANDSHAKE_H
#define LABLINK_HANDSHAKE_H

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

// ---------------------------------------------------------------------------
// MARK: - Protocol Constants
// ---------------------------------------------------------------------------

#define LABLINK_PROTOCOL_VERSION    1
#define LABLINK_MAGIC               0x4C4C4E4B  // "LLNK"
#define LABLINK_MAX_DEVICE_NAME     64
#define LABLINK_MAX_PAYLOAD         1472        // Max MTU for Cat 6 (1500 - 28 IP/UDP headers)
#define LABLINK_PIN_LENGTH          6
#define LABLINK_SPAKE2_POINT_SIZE   32
#define LABLINK_HMAC_SIZE           32
#define LABLINK_NONCE_SIZE          12
#define LABLINK_SESSION_KEY_SIZE    32

// ---------------------------------------------------------------------------
// MARK: - Packet Opcodes
// ---------------------------------------------------------------------------

typedef enum __attribute__((packed)) {
    LABLINK_OP_DISCOVER_REQ     = 0x01,  // Student → Teacher: "I exist"
    LABLINK_OP_DISCOVER_ACK     = 0x02,  // Teacher → Student: "I see you"
    LABLINK_OP_SPAKE2_INIT      = 0x10,  // Student → Teacher: SPAKE2+ pA
    LABLINK_OP_SPAKE2_RESPOND   = 0x11,  // Teacher → Student: SPAKE2+ pB
    LABLINK_OP_SPAKE2_CONFIRM   = 0x12,  // Student → Teacher: HMAC confirm
    LABLINK_OP_SPAKE2_VERIFIED  = 0x13,  // Teacher → Student: HMAC verified
    LABLINK_OP_PERMISSION_REQ   = 0x20,  // Student → Teacher: "May I view?"
    LABLINK_OP_PERMISSION_GRANT = 0x21,  // Teacher → Student: "Granted"
    LABLINK_OP_PERMISSION_DENY  = 0x22,  // Teacher → Student: "Denied"
    LABLINK_OP_STREAM_START     = 0x30,  // Teacher → Student: stream metadata
    LABLINK_OP_STREAM_DATA      = 0x31,  // Teacher → Student: encoded frame chunk
    LABLINK_OP_STREAM_END       = 0x3F,  // Teacher → Student: stream terminated
    LABLINK_OP_HEARTBEAT        = 0xF0,  // Bidirectional keepalive
    LABLINK_OP_TERMINATE        = 0xFF,  // Either → Either: kill session
} LabLinkOpcode;

// ---------------------------------------------------------------------------
// MARK: - Packet Header (12 bytes, fixed)
// ---------------------------------------------------------------------------

typedef struct __attribute__((packed)) {
    uint32_t    magic;              // LABLINK_MAGIC
    uint8_t     version;            // LABLINK_PROTOCOL_VERSION
    uint8_t     opcode;             // LabLinkOpcode
    uint16_t    payload_length;     // Length of payload following this header
    uint32_t    sequence;           // Monotonic sequence number
} LabLinkPacketHeader;

// ---------------------------------------------------------------------------
// MARK: - Discovery Payloads
// ---------------------------------------------------------------------------

typedef struct __attribute__((packed)) {
    char        device_name[LABLINK_MAX_DEVICE_NAME];
    uint8_t     role;               // 0 = Teacher, 1 = Student
} LabLinkDiscoverPayload;

// ---------------------------------------------------------------------------
// MARK: - SPAKE2+ Payloads
// ---------------------------------------------------------------------------

typedef struct __attribute__((packed)) {
    uint8_t     public_point[LABLINK_SPAKE2_POINT_SIZE];  // pA or pB
    uint8_t     nonce[LABLINK_NONCE_SIZE];
} LabLinkSPAKE2Payload;

typedef struct __attribute__((packed)) {
    uint8_t     confirm_hmac[LABLINK_HMAC_SIZE];
} LabLinkSPAKE2ConfirmPayload;

// ---------------------------------------------------------------------------
// MARK: - Stream Metadata
// ---------------------------------------------------------------------------

typedef enum __attribute__((packed)) {
    LABLINK_CODEC_HEVC_444          = 0x01,
    LABLINK_CODEC_PRORES_4444XQ     = 0x02,
    LABLINK_CODEC_PRORES_422_PROXY  = 0x03,  // M5 Ultra mode
} LabLinkCodecType;

typedef struct __attribute__((packed)) {
    uint8_t     codec;              // LabLinkCodecType
    uint16_t    width;
    uint16_t    height;
    uint8_t     fps;
    uint32_t    bitrate_kbps;       // Target bitrate in kbps
    bool        cursor_visible;
} LabLinkStreamMetadata;

// ---------------------------------------------------------------------------
// MARK: - Stream Data Payload
// ---------------------------------------------------------------------------

typedef struct __attribute__((packed)) {
    uint32_t    frame_id;           // Frame sequence
    uint16_t    chunk_index;        // Chunk index within frame
    uint16_t    chunk_total;        // Total chunks for this frame
    uint32_t    data_length;        // Actual data bytes in this packet
    // Followed by `data_length` bytes of encoded video data
} LabLinkStreamDataHeader;

#ifdef __cplusplus
}
#endif

#endif /* LABLINK_HANDSHAKE_H */
