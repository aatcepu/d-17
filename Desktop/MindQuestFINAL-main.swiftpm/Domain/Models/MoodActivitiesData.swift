import SwiftUI

// MARK: - Mood-Based Activity Recommendations Data
@MainActor
struct MoodActivities {
    
    static func recommendations(for moodEmoji: String, category: ActivityCategory) -> [ActivityRecommendation] {
        switch category {
        case .health:
            return healthActivities(for: moodEmoji)
        case .fitness:
            return fitnessActivities(for: moodEmoji)
        case .games:
            return gameActivities(for: moodEmoji)
        case .music:
            return musicActivities(for: moodEmoji)
        case .puzzles:
            return puzzleActivities(for: moodEmoji)
        }
    }
    
    // MARK: - Health
    private static func healthActivities(for mood: String) -> [ActivityRecommendation] {
        switch mood {
        case "🌟":
            return [
                ActivityRecommendation(category: .health, name: "Dance Challenge", description: "Channel your euphoria into a 5-min freestyle dance session!", icon: "figure.dance", duration: "5 min", difficulty: "Fun", accentColor: Theme.health, instructions: "Clear some space, pick an upbeat track, and dance freely for five minutes. Let your happiness move your body!", heroImage: "figure.dance"),
                ActivityRecommendation(category: .health, name: "Power Smoothie", description: "Blend your favorite fruits for a mood-boosting smoothie.", icon: "cup.and.saucer.fill", duration: "10 min", difficulty: "Easy", accentColor: Theme.health, instructions: "Gather fresh fruits, a liquid base, and a blender. Pulse until smooth and enjoy your nutritious boost.", heroImage: "cup.and.saucer.fill")
            ]
        case "😊":
            return [
                ActivityRecommendation(category: .health, name: "Stretching Flow", description: "Gentle full-body stretches to maintain your positive vibe.", icon: "figure.flexibility", duration: "8 min", difficulty: "Easy", accentColor: Theme.health, instructions: "Follow a sequence of neck rolls, arm reaches, and toe touches. Hold each stretch for 20 seconds.", heroImage: "figure.flexibility"),
                ActivityRecommendation(category: .health, name: "Healthy Snack Prep", description: "Prepare some nutritious snacks to fuel your day.", icon: "carrot.fill", duration: "15 min", difficulty: "Easy", accentColor: Theme.health, instructions: "Wash and slice some fresh vegetables or prepare a small bowl of nuts and seeds for a healthy energy source.", heroImage: "carrot.fill")
            ]
        case "😌":
            return [
                ActivityRecommendation(category: .health, name: "Yoga Flow", description: "A calming sequence of poses to deepen your serenity.", icon: "figure.yoga", duration: "15 min", difficulty: "Medium", accentColor: Theme.health, instructions: "Move slowly through mountain pose, downward dog, and child's pose. Focus on steady, deep breaths.", heroImage: "figure.yoga"),
                ActivityRecommendation(category: .health, name: "Herbal Tea Ritual", description: "Brew a soothing cup and practice mindful sipping.", icon: "mug.fill", duration: "10 min", difficulty: "Easy", accentColor: Theme.health, instructions: "Boil water, steep your favorite herbal tea for 5 minutes, and take small, deliberate sips while focusing on the warmth.", heroImage: "mug.fill")
            ]
        case "😕":
            return [
                ActivityRecommendation(category: .health, name: "Gentle Walk", description: "A light 10-minute walk to clear your mind.", icon: "figure.walk", duration: "10 min", difficulty: "Easy", accentColor: Theme.health, instructions: "Step outside or walk through your home at a relaxed pace. Observe your surroundings without judgment.", heroImage: "figure.walk"),
                ActivityRecommendation(category: .health, name: "Hydration Check", description: "Drink a full glass of water — dehydration affects mood.", icon: "drop.fill", duration: "2 min", difficulty: "Easy", accentColor: Theme.health, instructions: "Fill a large glass with fresh water. Drink it slowly, noticing the sensation of hydration.", heroImage: "drop.fill")
            ]
        case "😔":
            return [
                ActivityRecommendation(category: .health, name: "Body Scan", description: "Lie down and slowly notice each part of your body. Release tension.", icon: "person.crop.circle", duration: "10 min", difficulty: "Easy", accentColor: Theme.health, instructions: "Find a comfortable position. Mentally scan from your toes to your head, consciously relaxing each muscle group.", heroImage: "person.crop.circle.fill"),
                ActivityRecommendation(category: .health, name: "Warm Compress", description: "Apply warmth to your neck/shoulders for comfort.", icon: "flame.fill", duration: "5 min", difficulty: "Easy", accentColor: Theme.health, instructions: "Heat a damp towel or use a heating pad. Apply it to your shoulders and breathe deeply into the warmth.", heroImage: "flame.fill")
            ]
        default:
            return [
                ActivityRecommendation(category: .health, name: "Mindful Breathing", description: "Take 10 deep breaths to check in with yourself.", icon: "wind", duration: "3 min", difficulty: "Easy", accentColor: Theme.health, instructions: "Close your eyes. Inhale deeply for four counts, hold for two, and exhale slowly for six. Repeat ten times.", heroImage: "wind"),
                ActivityRecommendation(category: .health, name: "Acupressure Point", description: "Apply pressure to the Hegu point to reduce stress.", icon: "hand.raised.fill", duration: "5 min", difficulty: "Easy", accentColor: Theme.health, instructions: "Find the web between your thumb and index finger. Apply firm pressure for 1-2 minutes while breathing deeply.", heroImage: "hand.point.up.left.fill"),
                ActivityRecommendation(category: .health, name: "Posture Reset", description: "Align your spine and open your chest for better flow.", icon: "figure.stand", duration: "2 min", difficulty: "Easy", accentColor: Theme.health, instructions: "Roll your shoulders back, tuck your chin slightly, and imagine a string pulling the crown of your head upward.", heroImage: "figure.stand")
            ]
        }
    }
    
    // MARK: - Fitness
    private static func fitnessActivities(for mood: String) -> [ActivityRecommendation] {
        switch mood {
        case "🌟":
            return [
                ActivityRecommendation(category: .fitness, name: "HIIT Burst", description: "30 seconds on, 10 seconds off. Burpees, jump squats, mountain climbers!", icon: "bolt.heart.fill", duration: "7 min", difficulty: "Hard", accentColor: Theme.fitness, instructions: "Perform high-intensity movements (burpees, squats) for 30 seconds, followed by 10 seconds of rest. Repeat for 7 minutes.", heroImage: "bolt.heart.fill"),
                ActivityRecommendation(category: .fitness, name: "Sprint Intervals", description: "Alternate sprinting and jogging for max energy release.", icon: "figure.run", duration: "10 min", difficulty: "Hard", accentColor: Theme.fitness, instructions: "Sprint at full speed for 30 seconds, then jog slowly for 60 seconds to recover. Repeat for the full duration.", heroImage: "figure.run")
            ]
        case "😊":
            return [
                ActivityRecommendation(category: .fitness, name: "Cardio Mix", description: "Jumping jacks, high knees, and skipping — keep the joy flowing!", icon: "figure.jumprope", duration: "10 min", difficulty: "Medium", accentColor: Theme.fitness, instructions: "Cycle through jumping jacks, high knees, and skipping in place. Keep your heart rate up and maintain a steady rhythm.", heroImage: "figure.jumprope"),
                ActivityRecommendation(category: .fitness, name: "Outdoor Jog", description: "A scenic jog to enjoy the moment and boost endorphins.", icon: "figure.outdoor.cycle", duration: "15 min", difficulty: "Medium", accentColor: Theme.fitness, instructions: "Go for a light jog in a natural or scenic area. Focus on your breathing and the feeling of movement.", heroImage: "figure.walk")
            ]
        case "😌":
            return [
                ActivityRecommendation(category: .fitness, name: "Steady Walk", description: "A peaceful 20-minute walk at your own pace.", icon: "figure.walk", duration: "20 min", difficulty: "Easy", accentColor: Theme.fitness, instructions: "Walk at a comfortable, consistent pace. Pay attention to the sights and sounds around you to stay grounded.", heroImage: "figure.walk"),
                ActivityRecommendation(category: .fitness, name: "Tai Chi Flow", description: "Gentle, flowing movements for inner harmony.", icon: "figure.mind.and.body", duration: "15 min", difficulty: "Easy", accentColor: Theme.fitness, instructions: "Perform slow, deliberate movements that flow into each other. Focus on balance and internal energy.", heroImage: "figure.mind.and.body")
            ]
        case "😕":
            return [
                ActivityRecommendation(category: .fitness, name: "Light Stretches", description: "Easy stretches to release tension without overexertion.", icon: "figure.flexibility", duration: "8 min", difficulty: "Easy", accentColor: Theme.fitness, instructions: "Reach gently for your toes, stretch your arms overhead, and rotate your wrists. Hold each position for 15 seconds.", heroImage: "figure.flexibility"),
                ActivityRecommendation(category: .fitness, name: "Chair Exercises", description: "Simple seated movements to get blood flowing.", icon: "chair.fill", duration: "5 min", difficulty: "Easy", accentColor: Theme.fitness, instructions: "While seated, perform leg extensions, arm circles, and seated marches to improve circulation.", heroImage: "chair.fill")
            ]
        case "😔":
            return [
                ActivityRecommendation(category: .fitness, name: "Deep Breathing", description: "Box breathing: 4 seconds in, hold 4, out 4, hold 4.", icon: "wind", duration: "5 min", difficulty: "Easy", accentColor: Theme.fitness, instructions: "Inhale for four seconds, hold for four, exhale for four, and hold for four. Repeat to calm your nervous system.", heroImage: "wind"),
                ActivityRecommendation(category: .fitness, name: "Gentle Sway", description: "Stand and gently sway side to side. Small movements help.", icon: "figure.stand", duration: "3 min", difficulty: "Easy", accentColor: Theme.fitness, instructions: "Stand with feet shoulder-width apart. Slowly shift your weight from side to side in a rhythmic swaying motion.", heroImage: "figure.stand")
            ]
        default:
            return [
                ActivityRecommendation(category: .fitness, name: "Active Break", description: "Stand up, stretch, and move for a few minutes.", icon: "figure.stand", duration: "5 min", difficulty: "Easy", accentColor: Theme.fitness, instructions: "Step away from your desk. Reach high, touch your toes, and walk around your room for a quick reset.", heroImage: "figure.stand"),
                ActivityRecommendation(category: .fitness, name: "Wall Sit", description: "Build leg strength with this simple isometric hold.", icon: "figure.strengthtraining.functional", duration: "3 min", difficulty: "Hard", accentColor: Theme.fitness, instructions: "Lean against a wall and slide down until your thighs are parallel to the floor. Hold for as long as possible!", heroImage: "figure.strengthtraining.functional"),
                ActivityRecommendation(category: .fitness, name: "Speed Skaters", description: "Lateral jumps to boost your heart rate and agility.", icon: "figure.run", duration: "7 min", difficulty: "Hard", accentColor: Theme.fitness, instructions: "Jump side to side, landing on one foot with the other crossing behind. Swing your arms for momentum.", heroImage: "figure.run")
            ]
        }
    }
    
    // MARK: - Games
    private static func gameActivities(for mood: String) -> [ActivityRecommendation] {
        switch mood {
        case "🌟":
            return [
                ActivityRecommendation(category: .games, name: "Speed Puzzle", description: "Race against the clock to solve a pattern puzzle!", icon: "timer", duration: "5 min", difficulty: "Hard", accentColor: Theme.games, instructions: "Reconstruct the scrambled image by sliding pieces into the empty slot. Complete it before the timer runs out!", heroImage: "timer"),
                ActivityRecommendation(category: .games, name: "Reaction Test", description: "Tap as fast as you can when the color changes!", icon: "hand.tap.fill", duration: "3 min", difficulty: "Medium", accentColor: Theme.games, instructions: "Wait for the screen to turn green, then tap as quickly as possible. Your reaction time will be recorded.", heroImage: "hand.tap.fill")
            ]
        case "😊":
            return [
                ActivityRecommendation(category: .games, name: "Trivia Quiz", description: "Fun facts about wellness, science, and nature.", icon: "questionmark.circle.fill", duration: "5 min", difficulty: "Medium", accentColor: Theme.games, instructions: "Answer a series of multiple-choice questions. Each correct answer boosts your score and teaches you something new.", heroImage: "questionmark.circle.fill"),
                ActivityRecommendation(category: .games, name: "Word Builder", description: "Create as many words as possible from given letters.", icon: "textformat.abc", duration: "5 min", difficulty: "Medium", accentColor: Theme.games, instructions: "Use the provided set of letters to find as many words as you can. Longer words give more points!", heroImage: "textformat.abc")
            ]
        case "😌":
            return [
                ActivityRecommendation(category: .games, name: "Word Search", description: "Find hidden words in a peaceful letter grid.", icon: "magnifyingglass", duration: "10 min", difficulty: "Easy", accentColor: Theme.games, instructions: "Look for the words listed at the bottom of the screen within the grid. They can be horizontal, vertical, or diagonal.", heroImage: "magnifyingglass"),
                ActivityRecommendation(category: .games, name: "Zen Tapper", description: "Tap gently in harmony with a calming pattern.", icon: "circle.grid.3x3.fill", duration: "5 min", difficulty: "Easy", accentColor: Theme.games, instructions: "Watch the expanding circles and tap them exactly when they reach the outer ring. Maintain a steady flow.", heroImage: "circle.grid.3x3.fill")
            ]
        case "😕":
            return [
                ActivityRecommendation(category: .games, name: "Pattern Match", description: "Remember and reproduce a sequence of shapes.", icon: "square.grid.2x2.fill", duration: "5 min", difficulty: "Medium", accentColor: Theme.games, instructions: "Observe the sequence of shapes that flash on the grid. Repeat the sequence correctly to advance to higher levels.", heroImage: "square.grid.2x2.fill"),
                ActivityRecommendation(category: .games, name: "Color Sorting", description: "Sort colorful bubbles into the right containers.", icon: "circle.hexagongrid.fill", duration: "5 min", difficulty: "Easy", accentColor: Theme.games, instructions: "Drag each colored bubble into the basket of the matching color. Work quickly but accurately.", heroImage: "circle.hexagongrid.fill")
            ]
        case "😔":
            return [
                ActivityRecommendation(category: .games, name: "Color Flow", description: "Tap colored circles in a soothing sequence.", icon: "paintpalette.fill", duration: "5 min", difficulty: "Easy", accentColor: Theme.games, instructions: "Follow the evolving colors on screen. Tap each one as it highlights to shift the gradient smoothly.", heroImage: "paintpalette.fill"),
                ActivityRecommendation(category: .games, name: "Bubble Pop", description: "Pop bubbles gently for a calming, satisfying experience.", icon: "bubble.fill", duration: "3 min", difficulty: "Easy", accentColor: Theme.games, instructions: "Enjoy the satisfying sound and feel of popping bubbles. There's no rush, just tap each one as it appears.", heroImage: "bubble.fill")
            ]
        default:
            return [
                ActivityRecommendation(category: .games, name: "Quick Match", description: "A fun memory matching game.", icon: "rectangle.grid.2x2.fill", duration: "5 min", difficulty: "Easy", accentColor: Theme.games, instructions: "Flip two cards at a time to find matching pairs. Clear the entire board to win!", heroImage: "rectangle.grid.2x2.fill"),
                ActivityRecommendation(category: .games, name: "Memory Blitz", description: "Fast-paced pattern memorization challenge.", icon: "brain.head.profile", duration: "5 min", difficulty: "Medium", accentColor: Theme.games, instructions: "Watch the sequence of glowing tiles and repeat it exactly. Each level adds more complexity!", heroImage: "brain.head.profile"),
                ActivityRecommendation(category: .games, name: "Logic Link", description: "Connect matching nodes without crossing paths.", icon: "circle.grid.2x2.fill", duration: "8 min", difficulty: "Hard", accentColor: Theme.games, instructions: "Draw lines between identical icons. The paths cannot overlap. Solve the puzzle for all pairs!", heroImage: "circle.grid.2x2.fill")
            ]
        }
    }
    
    // MARK: - Music
    private static func musicActivities(for mood: String) -> [ActivityRecommendation] {
        switch mood {
        case "🌟":
            return [
                ActivityRecommendation(category: .music, name: "Upbeat Playlist", description: "High-energy tracks to match your euphoric vibe! 🎶", icon: "music.note", duration: "15 min", difficulty: "Fun", accentColor: Theme.music, instructions: "Put on your headphones and let the high-tempo beats amplify your energy. Feel free to move to the rhythm!", heroImage: "music.note.list"),
                ActivityRecommendation(category: .music, name: "Sing Along", description: "Belt out your favorite song — no judgment zone!", icon: "mic.fill", duration: "5 min", difficulty: "Fun", accentColor: Theme.music, instructions: "Pick a song you know by heart. Sing as loud as you want and express your joy through your voice.", heroImage: "mic.fill"),
                ActivityRecommendation(category: .music, name: "Victory Anthem", description: "Triumphant orchestral frequencies for peak joy.", icon: "star.fill", duration: "10 min", difficulty: "Fun", accentColor: Theme.music, instructions: "Close your eyes and let the sweeping, powerful tones celebrate your amazing mood. Feel every wave of victory!", heroImage: "star.fill")
            ]
        case "😊":
            return [
                ActivityRecommendation(category: .music, name: "Feel-Good Hits", description: "A curated mix of happy, positive songs.", icon: "music.note.list", duration: "15 min", difficulty: "Fun", accentColor: Theme.music, instructions: "Listen to tracks with positive lyrics and bright melodies. Let the music sustain your happy mood.", heroImage: "music.note.list"),
                ActivityRecommendation(category: .music, name: "Rhythm Clap", description: "Clap along to a beat pattern — fun and engaging!", icon: "hands.clap.fill", duration: "5 min", difficulty: "Easy", accentColor: Theme.music, instructions: "Follow the beat of the music by clapping your hands or tapping your feet in synchronization with the rhythm.", heroImage: "hands.clap.fill"),
                ActivityRecommendation(category: .music, name: "Sunshine Melody", description: "Bright, cheerful harmonics to sustain your smile.", icon: "sun.max.fill", duration: "10 min", difficulty: "Easy", accentColor: Theme.music, instructions: "Let the warm, sunlit harmonics wash over you. These uplifting tones are designed to keep your spirits high.", heroImage: "sun.max.fill")
            ]
        case "😌":
            return [
                ActivityRecommendation(category: .music, name: "Lo-fi Chill", description: "Lo-fi beats to study/relax to. Pure serenity.", icon: "headphones", duration: "20 min", difficulty: "Easy", accentColor: Theme.music, instructions: "Let the mellow, atmospheric lo-fi beats create a calm environment for relaxation or light focus.", heroImage: "headphones"),
                ActivityRecommendation(category: .music, name: "Nature Sounds", description: "Rain, ocean waves, or forest ambience for deep calm.", icon: "leaf.fill", duration: "15 min", difficulty: "Easy", accentColor: Theme.music, instructions: "Close your eyes and imagine yourself in nature. Focus on the soothing sounds of rain, waves, or wind.", heroImage: "leaf.fill"),
                ActivityRecommendation(category: .music, name: "Zen Drone", description: "A continuous meditative tone for deep stillness.", icon: "circle.circle.fill", duration: "15 min", difficulty: "Easy", accentColor: Theme.music, instructions: "Sit comfortably and let the single sustained drone tone fill your awareness. Focus on nothing but the sound.", heroImage: "circle.circle.fill")
            ]
        case "😕":
            return [
                ActivityRecommendation(category: .music, name: "Acoustic Calm", description: "Gentle acoustic guitar melodies for comfort.", icon: "guitars.fill", duration: "15 min", difficulty: "Easy", accentColor: Theme.music, instructions: "Focus on the simple, warm sounds of an acoustic guitar. Let the unplugged melodies soothe your thoughts.", heroImage: "guitars.fill"),
                ActivityRecommendation(category: .music, name: "Humming Exercise", description: "Hum a familiar tune — vibrations reduce anxiety.", icon: "waveform", duration: "5 min", difficulty: "Easy", accentColor: Theme.music, instructions: "Pick a simple melody and hum it softly. Feel the vibration in your throat and chest to ground yourself.", heroImage: "waveform"),
                ActivityRecommendation(category: .music, name: "Comfort Tone", description: "A warm, low-frequency hum to ease your mind.", icon: "speaker.wave.2.fill", duration: "10 min", difficulty: "Easy", accentColor: Theme.music, instructions: "Listen to the deep, warm bass frequencies. Let them act as a blanket of sound, wrapping you in comfort.", heroImage: "speaker.wave.2.fill")
            ]
        case "😔":
            return [
                ActivityRecommendation(category: .music, name: "Ambient Sounds", description: "Soft, slow ambient music for emotional healing.", icon: "waveform.path", duration: "15 min", difficulty: "Easy", accentColor: Theme.music, instructions: "Listen to shifting textures of ambient sound. Allow the music to hold space for your emotions without pressure.", heroImage: "waveform.path"),
                ActivityRecommendation(category: .music, name: "Sound Bath", description: "Close your eyes and let healing frequencies wash over you.", icon: "ear.fill", duration: "10 min", difficulty: "Easy", accentColor: Theme.music, instructions: "Experience deep resonant frequencies. Focus on the way the sound waves feel as they wash over your mind.", heroImage: "ear.fill"),
                ActivityRecommendation(category: .music, name: "Gentle Rain", description: "Soft rainfall sounds to soothe and cradle your spirit.", icon: "cloud.rain.fill", duration: "15 min", difficulty: "Easy", accentColor: Theme.music, instructions: "Imagine yourself under a warm shelter with gentle rain pattering around you. Let the rhythmic sound relax your body.", heroImage: "cloud.rain.fill")
            ]
        default:
            return [
                ActivityRecommendation(category: .music, name: "Calm Waves", description: "Deeply resonant frequencies for pure serenity.", icon: "waveform", duration: "10 min", difficulty: "Easy", accentColor: Theme.music, instructions: "Listen to the synthesized calm frequencies. Focus on your breathing and let the sound ground you.", heroImage: "waveform"),
                ActivityRecommendation(category: .music, name: "Focused Pulse", description: "Sustain your concentration with beta-waves.", icon: "brain", duration: "15 min", difficulty: "Easy", accentColor: Theme.music, instructions: "Use these rhythmic pulses to create a mental state of deep focus. Ideal for work or study.", heroImage: "brain"),
                ActivityRecommendation(category: .music, name: "Energetic Flow", description: "Uplifting tones to boost your movement.", icon: "bolt.fill", duration: "10 min", difficulty: "Easy", accentColor: Theme.music, instructions: "Let the high-energy frequency sweeps lift your mood and motivation. Move with the sound.", heroImage: "bolt.fill")
            ]
        }
    }
    
    // MARK: - Puzzles
    private static func puzzleActivities(for mood: String) -> [ActivityRecommendation] {
        switch mood {
        case "🌟":
            return [
                ActivityRecommendation(category: .puzzles, name: "Hard Sudoku", description: "Challenge your euphoric brain with an expert puzzle!", icon: "number.square.fill", duration: "15 min", difficulty: "Hard", accentColor: Theme.puzzles, instructions: "Fill the 9x9 grid with numbers 1-9 so that each row, column, and 3x3 section contains all digits once. Use your heightened energy to solve the complex logic!", heroImage: "number.square.fill"),
                ActivityRecommendation(category: .puzzles, name: "Logic Grid", description: "Solve a complex logic deduction puzzle.", icon: "square.grid.3x3.bottommiddle.filled", duration: "10 min", difficulty: "Hard", accentColor: Theme.puzzles, instructions: "Use the provided clues to cross-reference and eliminate possibilities in the grid. Deduce the only logical solution to the puzzle.", heroImage: "square.grid.3x3.fill"),
                ActivityRecommendation(category: .puzzles, name: "Speed Pattern Match", description: "Match patterns at lightning speed!", icon: "bolt.square.fill", duration: "5 min", difficulty: "Hard", accentColor: Theme.puzzles, instructions: "Observe the rapidly flashing pattern and recreate it. Each level gets faster — test your limits!", heroImage: "bolt.square.fill")
            ]
        case "😊":
            return [
                ActivityRecommendation(category: .puzzles, name: "Crossword", description: "A fun crossword with wellness-themed clues.", icon: "textformat.abc.dottedunderline", duration: "10 min", difficulty: "Medium", accentColor: Theme.puzzles, instructions: "Read the clues for 'Across' and 'Down' positions. Fill in the letters to complete words related to health and positivity.", heroImage: "textformat.abc.dottedunderline"),
                ActivityRecommendation(category: .puzzles, name: "Word Scramble", description: "Unscramble wellness words as fast as you can!", icon: "textformat.size", duration: "5 min", difficulty: "Medium", accentColor: Theme.puzzles, instructions: "Rearrange the jumbled letters to form words associated with well-being. Work quickly to clear the list.", heroImage: "textformat.size"),
                ActivityRecommendation(category: .puzzles, name: "Trivia Sprint", description: "Quick-fire wellness trivia to test your knowledge!", icon: "questionmark.diamond.fill", duration: "5 min", difficulty: "Medium", accentColor: Theme.puzzles, instructions: "Answer rapid wellness trivia questions. Score points for speed and accuracy!", heroImage: "questionmark.diamond.fill")
            ]
        case "😌":
            return [
                ActivityRecommendation(category: .puzzles, name: "Jigsaw Zen", description: "A calming jigsaw puzzle with nature imagery.", icon: "puzzlepiece.fill", duration: "15 min", difficulty: "Easy", accentColor: Theme.puzzles, instructions: "Fit the jigsaw pieces together to complete a beautiful, peaceful image of a natural landscape. Take your time.", heroImage: "puzzlepiece.fill"),
                ActivityRecommendation(category: .puzzles, name: "Spot the Difference", description: "Find subtle differences between two images.", icon: "eye.fill", duration: "5 min", difficulty: "Easy", accentColor: Theme.puzzles, instructions: "Compare the two side-by-side images carefully. Tap on the areas where you notice any differences.", heroImage: "eye.fill"),
                ActivityRecommendation(category: .puzzles, name: "Bubble Pop Zen", description: "Pop calming bubbles at your own pace.", icon: "bubble.fill", duration: "5 min", difficulty: "Easy", accentColor: Theme.puzzles, instructions: "Gently tap the floating bubbles. No rush, no score — just pure, meditative popping.", heroImage: "bubble.fill")
            ]
        case "😕":
            return [
                ActivityRecommendation(category: .puzzles, name: "Easy Riddles", description: "Fun riddles to distract and engage your mind.", icon: "lightbulb.fill", duration: "5 min", difficulty: "Easy", accentColor: Theme.puzzles, instructions: "Read each riddle and think creatively to find the solution. Use these clever challenges to redirect your focus.", heroImage: "lightbulb.fill"),
                ActivityRecommendation(category: .puzzles, name: "Number Path", description: "Connect numbers in sequence on a simple grid.", icon: "arrow.triangle.turn.up.right.diamond.fill", duration: "5 min", difficulty: "Easy", accentColor: Theme.puzzles, instructions: "Find a path through the grid by connecting numbers in their correct numerical order (1, 2, 3...).", heroImage: "arrow.triangle.turn.up.right.diamond.fill"),
                ActivityRecommendation(category: .puzzles, name: "Color Sorting Calm", description: "Sort colors into the right buckets to relax.", icon: "circle.hexagongrid.fill", duration: "5 min", difficulty: "Easy", accentColor: Theme.puzzles, instructions: "Drag colorful bubbles into matching containers. Focus on the satisfying order of sorting.", heroImage: "circle.hexagongrid.fill")
            ]
        case "😔":
            return [
                ActivityRecommendation(category: .puzzles, name: "Coloring Page", description: "Color in a beautiful mandala pattern. Pure therapy.", icon: "paintpalette.fill", duration: "15 min", difficulty: "Easy", accentColor: Theme.puzzles, instructions: "Tap the areas of the mandala to fill them with your chosen colors. Focus on the creative process and the beauty of the geometry.", heroImage: "paintpalette.fill"),
                ActivityRecommendation(category: .puzzles, name: "Simple Maze", description: "Guide a dot through a gentle, calming maze.", icon: "point.topleft.down.to.point.bottomright.curvepath.fill", duration: "5 min", difficulty: "Easy", accentColor: Theme.puzzles, instructions: "Navigate the dot from the start point to the exit of the maze. There are no dead ends, just a steady path forward.", heroImage: "point.topleft.down.to.point.bottomright.curvepath.fill"),
                ActivityRecommendation(category: .puzzles, name: "Bubble Pop Therapy", description: "Pop soothing bubbles to calm your mind.", icon: "bubble.left.and.bubble.right.fill", duration: "3 min", difficulty: "Easy", accentColor: Theme.puzzles, instructions: "Tap each floating bubble as it appears. The gentle pops and soft animations create a calming, therapeutic experience.", heroImage: "bubble.left.and.bubble.right.fill")
            ]
        default:
            return [
                ActivityRecommendation(category: .puzzles, name: "Brain Teaser", description: "A quick puzzle to exercise your mind.", icon: "brain.head.profile", duration: "5 min", difficulty: "Medium", accentColor: Theme.puzzles, instructions: "Solve a quick logic or pattern challenge designed to stimulate your mind and provide a mental reset.", heroImage: "brain.head.profile"),
                ActivityRecommendation(category: .puzzles, name: "Grid Explorer", description: "Navigate complex logic gates to reach the end.", icon: "square.grid.3x3.fill", duration: "12 min", difficulty: "Hard", accentColor: Theme.puzzles, instructions: "Connect the input and output nodes by rotating path tiles. Ensure a continuous flow to succeed.", heroImage: "square.grid.3x3.fill"),
                ActivityRecommendation(category: .puzzles, name: "Shape Sorter", description: "A relaxing geometric organization challenge.", icon: "circle.square.fill", duration: "5 min", difficulty: "Easy", accentColor: Theme.puzzles, instructions: "Arrange the scattered shapes into the target silhouettes. Focus on the spatial relationship between parts.", heroImage: "circle.square.fill")
            ]
        }
    }
}
