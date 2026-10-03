import SwiftUI

// MARK: - Sliding Puzzle (15 Puzzle)
struct SlidingPuzzleGame: View {
    @Environment(\.dismiss) var dismiss
    @State private var tiles: [Int] = []
    @State private var moves = 0
    @State private var isSolved = false
    @State private var timer: Timer?
    @State private var elapsed = 0
    
    private let gridSize = 4
    
    var body: some View {
        ZStack {
            Theme.navyGradient.ignoresSafeArea()
            
            VStack(spacing: 20) {
                AppHeader(
                    title: "Sliding Puzzle",
                    subtitle: "Moves: \(moves)",
                    showBackButton: true,
                    backAction: { dismiss() },
                    trailingView: Label(timeString, systemImage: "clock")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(Theme.textPrimary)
                        .asAnyView()
                )
                
                Text("Sliding Puzzle")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold).foregroundColor(Theme.textPrimary)
                
                if isSolved {
                    VStack(spacing: 16) {
                        Text("🧩").font(.system(size: 60))
                        Text("Solved!").font(.system(.title, design: .rounded)).fontWeight(.bold).foregroundColor(Theme.textPrimary)
                        Text("\(moves) moves in \(timeString)")
                            .font(.system(.subheadline, design: .rounded)).foregroundColor(Theme.secondary)
                        Button("Play Again") { resetPuzzle() }
                            .fontWeight(.bold).foregroundColor(.black)
                            .padding(.horizontal, 30).padding(.vertical, 12)
                            .background(Theme.secondary).cornerRadius(12)
                    }
                } else {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: gridSize), spacing: 4) {
                        ForEach(0..<tiles.count, id: \.self) { i in
                            let tile = tiles[i]
                            if tile == 0 {
                                Color.clear.frame(height: 72)
                            } else {
                                Button(action: { tapTile(at: i) }) {
                                    Text("\(tile)")
                                        .font(.system(.title, design: .rounded))
                                        .fontWeight(.bold)
                                        .foregroundColor(.white) // Tile numbers stay white if tiles are colored
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 72)
                                        .background(
                                            RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium)
                                                .fill(tileColor(tile))
                                        )
                                        .shadow(color: tileColor(tile).opacity(0.3), radius: 4)
                                        .overlay(RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium).stroke(Color.white.opacity(0.15), lineWidth: 0.5))
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Button(action: { resetPuzzle() }) {
                    Label("New Game", systemImage: "arrow.counterclockwise")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(Theme.puzzles)
                        .padding(.horizontal, 20).padding(.vertical, 10)
                        .background(Theme.puzzles.opacity(0.12))
                        .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding(.top, 20)
        }
        .onAppear { resetPuzzle() }
        .onDisappear { timer?.invalidate() }
    }
    
    private var timeString: String {
        let m = elapsed / 60; let s = elapsed % 60
        return String(format: "%d:%02d", m, s)
    }
    
    private func tileColor(_ tile: Int) -> Color {
        // Use a more premium, muted palette for the puzzle
        let colors: [Color] = [.blue, .purple, .indigo, .mint, .cyan, .teal, .blue.opacity(0.8), .purple.opacity(0.8)]
        return colors[tile % colors.count].opacity(0.85)
    }
    
    private func resetPuzzle() {
        moves = 0; elapsed = 0; isSolved = false
        timer?.invalidate()
        
        var arr = Array(0...15)
        repeat { arr.shuffle() } while !isSolvable(arr) || arr == Array(1...15) + [0]
        tiles = arr
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in elapsed += 1 }
    }
    
    private func tapTile(at index: Int) {
        let emptyIndex = tiles.firstIndex(of: 0)!
        let row = index / gridSize, col = index % gridSize
        let eRow = emptyIndex / gridSize, eCol = emptyIndex % gridSize
        
        if (abs(row - eRow) + abs(col - eCol)) == 1 {
            HapticAgent.shared.playImpact(.light, intensity: 0.5)
            withAnimation(.spring(response: 0.2)) { tiles.swapAt(index, emptyIndex) }
            moves += 1
            if tiles == Array(1...15) + [0] {
                isSolved = true
                timer?.invalidate()
                HapticAgent.shared.celebrateMilestone()
                EngagementAgent.shared.logPuzzleComplete()
            }
        }
    }
    
    private func isSolvable(_ puzzle: [Int]) -> Bool {
        var inversions = 0
        let flat = puzzle.filter { $0 != 0 }
        for i in 0..<flat.count {
            for j in (i+1)..<flat.count {
                if flat[i] > flat[j] { inversions += 1 }
            }
        }
        let emptyRow = puzzle.firstIndex(of: 0)! / gridSize
        if gridSize % 2 == 0 {
            return (inversions + emptyRow) % 2 == 1
        }
        return inversions % 2 == 0
    }
}

// MARK: - Reaction Test Game
struct ReactionTestGame: View {
    @Environment(\.dismiss) var dismiss
    @State private var phase: ReactionPhase = .waiting
    @State private var startTime: Date?
    @State private var reactionTime: Int = 0
    @State private var bestTime: Int = 9999
    @State private var attempts: [Int] = []
    
    enum ReactionPhase { case waiting, ready, tap, result }
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 24) {
                AppHeader(
                    title: "Reaction Test",
                    subtitle: bestTime < 9999 ? "Best: \(bestTime)ms" : "Test your speed",
                    showBackButton: true,
                    backAction: { dismiss() }
                )
                
                Spacer()
                
                VStack(spacing: 16) {
                    switch phase {
                    case .waiting:
                        Text("⚡").font(.system(size: 60))
                        Text("Tap when the screen turns GREEN")
                            .font(.system(.title3, design: .rounded)).fontWeight(.bold)
                            .foregroundColor(Theme.textPrimary)
                        Text("Tap anywhere to start")
                            .font(.system(.subheadline, design: .rounded)).foregroundColor(Theme.textSecondary.opacity(0.8))
                        
                    case .ready:
                        Text("Wait for green...")
                            .font(.system(.title2, design: .rounded)).fontWeight(.bold)
                            .foregroundColor(Theme.textPrimary)
                        
                    case .tap:
                        Text("TAP NOW!")
                            .font(.system(.largeTitle, design: .rounded)).fontWeight(.black)
                            .foregroundColor(Theme.textPrimary)
                        
                    case .result:
                        Text("⚡").font(.system(size: 60))
                        Text("\(reactionTime) ms")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.textPrimary)
                        Text(reactionRating)
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(Theme.textPrimary.opacity(0.8))
                        
                        if attempts.count >= 2 {
                            Text("Avg: \(attempts.reduce(0, +) / attempts.count)ms")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(Theme.textSecondary)
                        }
                        
                        Text("Tap to try again")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))
                            .padding(.top, 8)
                    }
                }
                
                Spacer()
            }
            .padding(.top, 20)
        }
        .onTapGesture { handleTap() }
    }
    
    private var backgroundColor: Color {
        switch phase {
        case .waiting: return Color(red: 0.05, green: 0.05, blue: 0.1)
        case .ready: return Color(red: 0.6, green: 0.15, blue: 0.15)
        case .tap: return Color(red: 0.15, green: 0.6, blue: 0.2)
        case .result: return Color(red: 0.05, green: 0.05, blue: 0.1)
        }
    }
    
    private var reactionRating: String {
        if reactionTime < 200 { return "Lightning fast! ⚡" }
        if reactionTime < 300 { return "Great reflexes! 🔥" }
        if reactionTime < 400 { return "Good reaction! 👍" }
        if reactionTime < 500 { return "Not bad! 😊" }
        return "Keep practicing! 💪"
    }
    
    private func handleTap() {
        switch phase {
        case .waiting:
            HapticAgent.shared.playImpact(.light)
            phase = .ready
            let delay = Double.random(in: 1.5...4.0)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if self.phase == .ready {
                    self.phase = .tap
                    self.startTime = Date()
                    HapticAgent.shared.playImpact(.rigid)
                }
            }
        case .ready:
            // Tapped too early
            HapticAgent.shared.gentleWarning()
            phase = .waiting
        case .tap:
            let elapsed = Date().timeIntervalSince(startTime ?? Date())
            reactionTime = Int(elapsed * 1000)
            bestTime = min(bestTime, reactionTime)
            attempts.append(reactionTime)
            HapticAgent.shared.celebrateSuccess()
            phase = .result
        case .result:
            HapticAgent.shared.playImpact(.light)
            phase = .ready
            let delay = Double.random(in: 1.5...4.0)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if self.phase == .ready {
                    self.phase = .tap
                    self.startTime = Date()
                    HapticAgent.shared.playImpact(.rigid)
                }
            }
        }
    }
}

// MARK: - Number Path Puzzle
struct NumberPathGame: View {
    @Environment(\.dismiss) var dismiss
    @State private var grid: [[Int]]
    @State private var path: [GridPos] = []
    @State private var nextNumber = 1
    @State private var level = 1
    @State private var isSolved = false
    @State private var score = 0
    @State private var wrongTap = false
    @State private var timer: Timer?
    @State private var elapsed = 0
    
    private let size = 5
    private var maxNum: Int { min(8 + level, size * size / 2) }
    
    struct GridPos: Equatable, Hashable {
        let row: Int, col: Int
    }
    
    init() {
        // Initialize grid with zeros to prevent empty array crash
        _grid = State(initialValue: Array(repeating: Array(repeating: 0, count: 5), count: 5))
    }
    
    var body: some View {
        ZStack {
            Theme.navyGradient.ignoresSafeArea()
            
            VStack(spacing: 16) {
                AppHeader(
                    title: "Number Path",
                    subtitle: "Level \(level)",
                    showBackButton: true,
                    backAction: { dismiss() },
                    trailingView: HStack(spacing: 8) {
                        Label(timeString, systemImage: "clock")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(Theme.textSecondary)
                        Text("\(score) pts")
                            .font(.system(.subheadline, design: .rounded).bold())
                            .foregroundColor(Theme.secondary)
                    }.asAnyView()
                )
                
                VStack(spacing: 6) {
                    Text("Tap numbers in order: 1 → \(maxNum)")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(Theme.puzzles)
                    
                    if !isSolved {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Theme.glassBackground).frame(height: 6)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Theme.puzzles)
                                    .frame(width: geo.size.width * CGFloat(nextNumber - 1) / CGFloat(maxNum), height: 6)
                                    .animation(.spring(response: 0.3), value: nextNumber)
                            }
                        }
                        .frame(height: 6).padding(.horizontal, 40)
                        
                        Text("\(nextNumber - 1)/\(maxNum) found")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(Theme.textSecondary)
                    }
                }
                
                if isSolved {
                    Spacer()
                    VStack(spacing: 16) {
                        Text("🎯").font(.system(size: 70))
                        Text("Path Complete!")
                            .font(.system(.title, design: .rounded)).fontWeight(.bold)
                            .foregroundColor(Theme.textPrimary)
                        Text("Solved in \(timeString) • +\(level * 10) pts")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(Theme.secondary)
                        Button(action: { level += 1; generateGrid() }) {
                            HStack { Text("Next Level"); Image(systemName: "arrow.right") }
                                .fontWeight(.bold).foregroundColor(.black)
                                .padding(.horizontal, 30).padding(.vertical, 14)
                                .background(Theme.puzzles).cornerRadius(14)
                        }
                    }
                    Spacer()
                } else {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: size), spacing: 6) {
                        ForEach(0..<size, id: \.self) { row in
                            ForEach(0..<size, id: \.self) { col in
                                let pos = GridPos(row: row, col: col)
                                let val = grid[row][col]
                                let isInPath = path.contains(pos)
                                let isNext = val == nextNumber
                                
                                Button(action: { tapCell(pos) }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(cellColor(val: val, inPath: isInPath, isNext: isNext))
                                            .frame(height: 56)
                                        if val > 0 {
                                            Text("\(val)")
                                                .font(.system(isNext ? .title2 : .title3, design: .rounded))
                                                .fontWeight(.bold)
                                                .foregroundColor(isInPath ? .white : isNext ? Theme.puzzles : Theme.textPrimary.opacity(0.6))
                                        }
                                    }
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(isNext ? Theme.puzzles : isInPath ? Theme.puzzles.opacity(0.4) : Theme.divider, lineWidth: isNext ? 2.5 : 0.5)
                                    )
                                    .scaleEffect(isNext ? 1.08 : 1.0)
                                    .animation(.spring(response: 0.3), value: nextNumber)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .disabled(isInPath)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    if wrongTap {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.orange)
                            Text("Find number \(nextNumber)!").foregroundColor(.orange)
                        }
                        .font(.system(.caption, design: .rounded).bold())
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    HStack(spacing: 16) {
                        Button(action: { resetPath() }) {
                            Label("Reset", systemImage: "arrow.counterclockwise")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 20).padding(.vertical, 10)
                                .background(Color.white.opacity(0.05)).cornerRadius(10)
                        }
                        Button(action: { generateGrid() }) {
                            Label("New Grid", systemImage: "shuffle")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(Theme.puzzles)
                                .padding(.horizontal, 20).padding(.vertical, 10)
                                .background(Theme.puzzles.opacity(0.1)).cornerRadius(10)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.top, 20)
        }
        .onAppear { generateGrid() }
        .onDisappear { timer?.invalidate() }
    }
    
    private var timeString: String {
        let m = elapsed / 60; let s = elapsed % 60
        return String(format: "%d:%02d", m, s)
    }
    
    private func cellColor(val: Int, inPath: Bool, isNext: Bool) -> Color {
        if inPath { return Theme.puzzles.opacity(0.5) }
        if isNext { return Theme.puzzles.opacity(0.15) }
        if val > 0 { return Theme.glassBackground }
        return Theme.glassBackground.opacity(0.3)
    }
    
    private func generateGrid() {
        isSolved = false
        nextNumber = 1
        path = []
        wrongTap = false
        elapsed = 0
        timer?.invalidate()
        
        // Build a guaranteed connected path using backtracking
        let target = maxNum
        var bestPath: [(Int, Int)] = []
        
        for _ in 0..<20 {
            let sr = Int.random(in: 0..<size)
            let sc = Int.random(in: 0..<size)
            let candidate = buildPath(from: (sr, sc), length: target)
            if candidate.count > bestPath.count { bestPath = candidate }
            if bestPath.count >= target { break }
        }
        
        var newGrid = Array(repeating: Array(repeating: 0, count: size), count: size)
        for (i, pos) in bestPath.enumerated() {
            newGrid[pos.0][pos.1] = i + 1
        }
        grid = newGrid
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if !isSolved { elapsed += 1 }
        }
    }
    
    /// Builds a connected path using depth-first backtracking
    private func buildPath(from start: (Int, Int), length: Int) -> [(Int, Int)] {
        var visited = Set<String>()
        var currentPath: [(Int, Int)] = []
        
        func walk(row: Int, col: Int) -> Bool {
            if currentPath.count >= length { return true }
            let key = "\(row),\(col)"
            guard row >= 0, row < size, col >= 0, col < size, !visited.contains(key) else { return false }
            
            visited.insert(key)
            currentPath.append((row, col))
            
            for (dr, dc) in [(0,1),(0,-1),(1,0),(-1,0)].shuffled() {
                if walk(row: row + dr, col: col + dc) { return true }
            }
            
            currentPath.removeLast()
            visited.remove(key)
            return false
        }
        
        _ = walk(row: start.0, col: start.1)
        return currentPath
    }
    
    private func tapCell(_ pos: GridPos) {
        let val = grid[pos.row][pos.col]
        
        if val == nextNumber {
            HapticAgent.shared.playImpact(.light, intensity: 0.5)
            withAnimation(.spring(response: 0.2)) {
                path.append(pos)
                nextNumber += 1
                wrongTap = false
            }
            if nextNumber > maxNum {
                score += level * 10
                timer?.invalidate()
                HapticAgent.shared.celebrateMilestone()
                EngagementAgent.shared.logPuzzleComplete()
                withAnimation(.spring()) { isSolved = true }
            }
        } else if val > 0 && !path.contains(pos) {
            HapticAgent.shared.gentleWarning()
            withAnimation(.spring(response: 0.3)) { wrongTap = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation { wrongTap = false }
            }
        }
    }
    
    private func resetPath() {
        withAnimation {
            path = []
            nextNumber = 1
            wrongTap = false
        }
    }
}

// MARK: - Bubble Pop Game
struct BubblePopGame: View {
    @Environment(\.dismiss) var dismiss
    @State private var bubbles: [PopBubble] = []
    @State private var score = 0
    @State private var timeRemaining = 30
    @State private var gameOver = false
    @State private var timer: Timer?
    @State private var spawnTimer: Timer?
    
    var body: some View {
        ZStack {
            Theme.navyGradient.ignoresSafeArea()
            
            VStack {
                AppHeader(
                    title: "Bubble Pop",
                    subtitle: "Score: \(score)",
                    showBackButton: true,
                    backAction: { dismiss() },
                    trailingView: Text("\(timeRemaining)s")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(timeRemaining <= 10 ? .red : Theme.secondary)
                        .asAnyView()
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            
            if gameOver {
                VStack(spacing: 16) {
                    Text("🫧").font(.system(size: 60))
                    Text("Time's Up!").font(.system(.title, design: .rounded)).fontWeight(.bold).foregroundColor(Theme.textPrimary)
                    Text("Score: \(score)").font(.system(.title2, design: .rounded)).foregroundColor(Theme.secondary)
                    Button("Play Again") { resetGame() }
                        .fontWeight(.bold).foregroundColor(.black)
                        .padding(.horizontal, 30).padding(.vertical, 12)
                        .background(Theme.secondary).cornerRadius(12)
                }
            } else {
                ForEach(bubbles) { bubble in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [bubble.color.opacity(0.8), bubble.color.opacity(0.4)],
                                center: .topLeading, startRadius: 0, endRadius: bubble.size
                            )
                        )
                        .frame(width: bubble.size, height: bubble.size)
                        .overlay(
                            Circle().stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                        )
                        .shadow(color: bubble.color.opacity(0.4), radius: 10)
                        .position(bubble.position)
                        .onTapGesture { popBubble(bubble) }
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .onAppear { resetGame() }
        .onDisappear { timer?.invalidate(); spawnTimer?.invalidate() }
    }
    
    private func resetGame() {
        score = 0; timeRemaining = 30; gameOver = false; bubbles = []
        timer?.invalidate(); spawnTimer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
                if timeRemaining <= 3 && timeRemaining > 0 { HapticAgent.shared.countdownTick() }
            }
            else { timer?.invalidate(); spawnTimer?.invalidate(); HapticAgent.shared.celebrateSuccess(); EngagementAgent.shared.logPuzzleComplete(); withAnimation { gameOver = true } }
        }
        
        spawnTimer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { _ in
            if bubbles.count < 12 && !gameOver { spawnBubble() }
        }
    }
    
    private func spawnBubble() {
        let colors: [Color] = [.pink, .purple, .blue, .cyan, .mint, .green, .yellow, .orange]
        let size = CGFloat.random(in: 40...80)
        let bubble = PopBubble(
            color: colors.randomElement()!,
            size: size,
            position: CGPoint(
                x: CGFloat.random(in: 40...340),
                y: CGFloat.random(in: 120...700)
            ),
            points: Int(90 / size * 10)
        )
        withAnimation(.spring(response: 0.4)) { bubbles.append(bubble) }
        
        // Auto-remove after a while
        let id = bubble.id
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 2...4)) {
            withAnimation { bubbles.removeAll { $0.id == id } }
        }
    }
    
    private func popBubble(_ bubble: PopBubble) {
        HapticAgent.shared.playImpact(.light)
        score += bubble.points
        withAnimation(.spring(response: 0.2)) { bubbles.removeAll { $0.id == bubble.id } }
    }
}

struct PopBubble: Identifiable {
    let id = UUID()
    let color: Color
    let size: CGFloat
    let position: CGPoint
    let points: Int
}

// MARK: - Maze Game
struct MazeGame: View {
    @Environment(\.dismiss) var dismiss
    @State private var playerPos = GridPos(row: 0, col: 0)
    @State private var level = 1
    @State private var isSolved = false
    @State private var moves = 0
    @State private var walls: Set<String> = []
    
    private let size = 7
    
    struct GridPos: Equatable { let row: Int, col: Int }
    
    private var goalPos: GridPos { GridPos(row: size - 1, col: size - 1) }
    
    var body: some View {
        ZStack {
            Theme.navyGradient.ignoresSafeArea()
            
            VStack(spacing: 20) {
                AppHeader(
                    title: "Maze",
                    subtitle: "Level \(level) • \(moves) moves",
                    showBackButton: true,
                    backAction: { dismiss() }
                )
                
                Text("Reach the 🏁")
                    .font(.system(.title3, design: .rounded)).fontWeight(.bold).foregroundColor(Theme.textPrimary)
                
                if isSolved {
                    VStack(spacing: 16) {
                        Text("🏆").font(.system(size: 60))
                        Text("Maze Cleared!").font(.system(.title, design: .rounded)).fontWeight(.bold).foregroundColor(Theme.textPrimary)
                        Button("Next Maze") { level += 1; resetMaze() }
                            .fontWeight(.bold).foregroundColor(.black)
                            .padding(.horizontal, 30).padding(.vertical, 12)
                            .background(Theme.secondary).cornerRadius(12)
                    }
                } else {
                    // Maze Grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: size), spacing: 3) {
                        ForEach(0..<size, id: \.self) { row in
                            ForEach(0..<size, id: \.self) { col in
                                let isWall = walls.contains("\(row),\(col)")
                                let isPlayer = playerPos.row == row && playerPos.col == col
                                let isGoal = row == size - 1 && col == size - 1
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(isWall ? Theme.divider : Theme.glassBackground.opacity(0.5))
                                        .frame(height: 42)
                                    
                                    if isPlayer {
                                        Circle()
                                            .fill(Theme.secondary)
                                            .frame(width: 24, height: 24)
                                            .shadow(color: Theme.secondary.opacity(0.5), radius: 5)
                                    } else if isGoal {
                                        Text("🏁").font(.system(size: 18))
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // D-Pad Controls
                    VStack(spacing: 12) {
                        Button(action: { movePlayer(dr: -1, dc: 0) }) {
                            Image(systemName: "chevron.up").font(.title2).foregroundColor(.white)
                                .frame(width: 64, height: 50)
                                .background(Theme.glassBackground)
                                .cornerRadius(Theme.cornerRadiusSmall)
                        }
                        HStack(spacing: 12) {
                            Button(action: { movePlayer(dr: 0, dc: -1) }) {
                                Image(systemName: "chevron.left").font(.title2).foregroundColor(.white)
                                    .frame(width: 64, height: 50)
                                    .background(Theme.glassBackground)
                                    .cornerRadius(Theme.cornerRadiusSmall)
                            }
                            Button(action: { movePlayer(dr: 0, dc: 1) }) {
                                Image(systemName: "chevron.right").font(.title2).foregroundColor(.white)
                                    .frame(width: 64, height: 50)
                                    .background(Theme.glassBackground)
                                    .cornerRadius(Theme.cornerRadiusSmall)
                            }
                        }
                        Button(action: { movePlayer(dr: 1, dc: 0) }) {
                            Image(systemName: "chevron.down").font(.title2).foregroundColor(.white)
                                .frame(width: 64, height: 50)
                                .background(Theme.glassBackground)
                                .cornerRadius(Theme.cornerRadiusSmall)
                        }
                    }
                    .padding(.bottom, 30)
                }
                
                Spacer()
            }
            .padding(.top, 20)
        }
        .onAppear { resetMaze() }
    }
    
    private func resetMaze() {
        playerPos = GridPos(row: 0, col: 0)
        moves = 0; isSolved = false
        generateMazeData()
    }
    
    private func generateMazeData() {
        // Build an impenetrable grid of walls
        var newWalls = Set<String>()
        for r in 0..<size {
            for c in 0..<size {
                newWalls.insert("\(r),\(c)")
            }
        }
        
        var visited = Set<String>()
        
        func carve(r: Int, c: Int) {
            newWalls.remove("\(r),\(c)")
            visited.insert("\(r),\(c)")
            
            // Randomize the order of carving directions
            let directions = [(0, 2), (2, 0), (0, -2), (-2, 0)].shuffled()
            for (dr, dc) in directions {
                let nr = r + dr, nc = c + dc
                if nr >= 0 && nr < size && nc >= 0 && nc < size && !visited.contains("\(nr),\(nc)") {
                    // Carve through the wall block between cells
                    newWalls.remove("\(r + dr/2),\(c + dc/2)")
                    carve(r: nr, c: nc)
                }
            }
        }
        
        carve(r: 0, c: 0)
        
        // Final safety guarantee
        newWalls.remove("\(size-1),\(size-1)")
        walls = newWalls
    }
    
    private func movePlayer(dr: Int, dc: Int) {
        let newR = playerPos.row + dr, newC = playerPos.col + dc
        guard newR >= 0, newR < size, newC >= 0, newC < size else { return }
        guard !walls.contains("\(newR),\(newC)") else {
            HapticAgent.shared.playImpact(.rigid, intensity: 0.3)
            return
        }
        
        HapticAgent.shared.playImpact(.light, intensity: 0.4)
        withAnimation(.spring(response: 0.2)) { playerPos = GridPos(row: newR, col: newC) }
        moves += 1
        
        if playerPos == goalPos {
            HapticAgent.shared.celebrateMilestone()
            EngagementAgent.shared.logPuzzleComplete()
            withAnimation { isSolved = true }
        }
    }
}
