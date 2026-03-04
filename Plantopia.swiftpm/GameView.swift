import SwiftUI


enum GrowthStage { case seed, sprout, young, mature }
enum LightLocation: String, CaseIterable {
    case indoor = "Indoor"
    case window = "Window"
    case outdoor = "Outdoor"
}


struct DayLesson {
    let title: String
    let body: String
    let emoji: String
    let actionPrompt: String
}


let scriptedLessons: [Int: DayLesson] = [
    1: DayLesson(
        title: "Your Seed Needs Water",
        body: "Every plant starts its journey needing moisture to germinate. Without water, seeds stay dormant forever.",
        emoji: "💧",
        actionPrompt: "Tap Water to give it a drink, then press Next Day."
    ),
    3: DayLesson(
        title: "Light Fuels Growth",
        body: "Plants convert sunlight into energy through photosynthesis. A seedling near a window gets the gentle light it needs to sprout.",
        emoji: "☀️",
        actionPrompt: "Make sure your plant is at the Window, then press Next Day."
    ),
    5: DayLesson(
        title: "Heavy Rain = Overwatering",
        body: "Today's heavy rain soaked your plant. Waterlogged soil suffocates roots, causing the same damage as over-watering from a can — yellow leaves and root rot.",
        emoji: "🌧️",
        actionPrompt: "Move to Indoor to help it dry out, then press Next Day."
    ),
    7: DayLesson(
        title: "Pests Love Weak Plants",
        body: "Insects attack stressed plants. You can fight them off with a mist treatment before they spread and cause real damage.",
        emoji: "🐛",
        actionPrompt: "Tap Treat to remove the pests, then press Next Day."
    ),
    10: DayLesson(
        title: "Consistency Equals Growth",
        body: "Plants that receive steady care — not too much, not too little — reach maturity. You have almost grown yours to full size!",
        emoji: "🌿",
        actionPrompt: "Keep conditions stable and press Next Day to reach maturity."
    ),
    12: DayLesson(
        title: "Your Plant is Fully Grown!",
        body: "A healthy mature plant is the reward for patient, consistent care. Everything you practised here applies to real plants at home.",
        emoji: "🌸",
        actionPrompt: "Tap Restart to plant a new seed and try again!"
    )
]


class PlantGameEngine: ObservableObject {

    @Published var water = 60
    @Published var sunlight = 40
    @Published var health = 100
    @Published var days = 0

    @Published var stage: GrowthStage = .seed
    @Published var location: LightLocation = .window
    @Published var activePests = false
    @Published var isOverwatered = false

    @Published var currentLesson: DayLesson? = nil
    @Published var showLesson = false
    @Published var isFinished = false
    @Published var isDead = false
    @Published var weatherEvent: String = "Clear Skies ☀️"

    func advance() {
        guard !isFinished && !isDead else { return }
        days += 1
        applyDayChanges()
        updateGrowthStage()
        
        if health <= 0 {
            isDead = true
            return
        }
        checkForLesson()
    }

    private func applyDayChanges() {
        
        weatherEvent = "Clear Skies ☀️"

        if days == 5 {
            weatherEvent = "Heavy Rain 🌧️"
            water = 90
            isOverwatered = true
        }
        
        if days == 7 {
            weatherEvent = "Pest Attack 🐛"
            activePests = true
        }

        water = max(water - 5, 0)

        
        switch location {
        case .indoor:  sunlight = max(sunlight - 8, 0)
        case .window:  sunlight = min(max(sunlight + 2, 0), 70)
        case .outdoor: sunlight = min(sunlight + 15, 100)
        }

        
        if water > 75 || isOverwatered {
            if water <= 75 { isOverwatered = false }  
            health = max(health - 15, 0)
        } else if water < 15 {
            health = max(health - 15, 0)
        } else if activePests {
            health = max(health - 15, 0)
        } else {
            
            health = min(health + 5, 100)
            isOverwatered = false
        }
    }

    private func updateGrowthStage() {
        if      days >= 12 && health > 50 { stage = .mature }
        else if days >= 7  && health > 50 { stage = .young  }
        else if days >= 3  && health > 50 { stage = .sprout }
    }

    private func checkForLesson() {
        if let lesson = scriptedLessons[days] {
            currentLesson = lesson
            showLesson = true
            
            if days == 12 && health > 0 { isFinished = true }
        }
    }

    func waterPlant()  { water = min(water + 25, 100) }

    func mistOrTreat() {
        if activePests {
            activePests = false
            health = min(health + 10, 100)
        } else {
            health = min(health + 5, 100)
        }
    }

    func restart() {
        water = 60; sunlight = 40; health = 100; days = 0
        stage = .seed; location = .window
        activePests = false; isOverwatered = false
        currentLesson = nil; showLesson = false; isFinished = false; isDead = false
        weatherEvent = "Clear Skies ☀️"
    }
}

struct GameView: View {
    @StateObject private var engine = PlantGameEngine()

    var body: some View {
        ZStack {
            backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar.padding(.bottom, 14)
                plantStage.padding(.bottom, 6)
                statsRow.padding(.horizontal).padding(.bottom, 14)
                actionRow.padding(.horizontal).padding(.bottom, 16)
                nextDayButton.padding(.horizontal)
            }
            .padding(.top, 8)

            if engine.showLesson, let lesson = engine.currentLesson {
                LessonCard(
                    lesson: lesson,
                    isFinished: engine.isFinished,
                    onDismiss: { withAnimation(.spring()) { engine.showLesson = false } },
                    onRestart: { withAnimation(.spring()) { engine.restart() } }
                )
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .zIndex(10)
            }

            if engine.isDead {
                deathOverlay
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    .zIndex(11)
            }
        }
    }

    var backgroundGradient: LinearGradient {
        let top: Color = engine.isOverwatered
            ? Color(red: 0.78, green: 0.88, blue: 0.97)
            : engine.activePests
                ? Color(red: 0.95, green: 0.92, blue: 0.78)
                : Color(red: 0.88, green: 0.97, blue: 0.9)
        return LinearGradient(
            colors: [top, Color(red: 0.82, green: 0.95, blue: 0.84)],
            startPoint: .top, endPoint: .bottom
        )
    }

    var headerBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Day \(engine.days) of 12")
                    .font(.title3.bold())
                HStack(spacing: 6) {
                    Text(stageName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    if engine.days > 0 {
                        Text("·")
                            .foregroundColor(.secondary)
                        Text(engine.weatherEvent)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            Spacer()
            HStack(spacing: 5) {
                ForEach(0..<12, id: \.self) { i in
                    Circle()
                        .fill(i < engine.days
                              ? Color(red: 0.22, green: 0.55, blue: 0.28)
                              : Color.white.opacity(0.6))
                        .frame(width: 7, height: 7)
                        .animation(.spring(), value: engine.days)
                }
            }
            Spacer()
            Button { withAnimation { engine.restart() } } label: {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.85))
                        .frame(width: 40, height: 40)
                        .shadow(color: .black.opacity(0.07), radius: 5)
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(.horizontal)
    }

    var stageName: String {
        switch engine.stage {
        case .seed:   return "🌰 Seed — just planted"
        case .sprout: return "🌱 Sprouting!"
        case .young:  return "🌿 Growing strong"
        case .mature: return "🌸 Fully grown!"
        }
    }

    var plantStage: some View {
        ZStack {
            plantVisual
            if engine.activePests {
                Text("🐛").font(.system(size: 32))
                    .offset(x: 44, y: -20)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(height: 210)
    }

    var plantVisual: some View {
        let growth    = CGFloat(min(Double(engine.days) / 12.0, 1.0))
        let unhealthy = engine.isOverwatered || engine.health < 40
        let color: Color = unhealthy
            ? Color(red: 0.72, green: 0.62, blue: 0.18)
            : Color(red: 0.22, green: 0.58, blue: 0.26)
        let wilt: Double = engine.health < 50 ? -14 : 0

        return VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(color)
                    .frame(width: 6, height: 18 + growth * 95)
                    .rotationEffect(.degrees(wilt), anchor: .bottom)
                    .animation(.easeInOut(duration: 0.6), value: wilt)

                if engine.stage != .seed {
                    Leaf(size: 32, color: color, isLeft: true).offset(x: -17, y: -20)
                    Leaf(size: 32, color: color, isLeft: false).offset(x:  17, y: -48)
                }
                if engine.stage == .young || engine.stage == .mature {
                    Leaf(size: 44, color: color, isLeft: true).offset(x: -26, y: -70)
                    Leaf(size: 44, color: color, isLeft: false).offset(x:  26, y: -96)
                }
                if engine.stage == .mature {
                    flowerView
                        .offset(y: -130 - growth * 18)
                        .transition(.scale.combined(with: .opacity))
                }
            }

            RoundedRectangle(cornerRadius: 6)
                .fill(engine.isOverwatered
                      ? Color(red: 0.42, green: 0.24, blue: 0.1)
                      : Color.brown)
                .frame(width: 54, height: 42)
                .animation(.easeInOut, value: engine.isOverwatered)
        }
    }

    var flowerView: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { i in
                Ellipse()
                    .fill(Color.pink.opacity(0.85))
                    .frame(width: 11, height: 6)
                    .offset(y: -9)
                    .rotationEffect(.degrees(Double(i) * 60))
            }
            Circle().fill(Color.yellow).frame(width: 10, height: 10)
        }
    }

    var statsRow: some View {
        HStack(spacing: 10) {
            StatPill(icon: "drop.fill",    label: "Water",  value: engine.water,    color: .blue)
            StatPill(icon: "sun.max.fill", label: "Light",  value: engine.sunlight, color: .orange)
            StatPill(icon: "heart.fill",   label: "Health", value: engine.health,
                     color: engine.health < 35 ? .red : engine.health < 65 ? .orange : .green)
        }
    }

    var actionRow: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                TapButton(
                    icon: "drop.fill", label: "Water", color: .blue,
                    warn: engine.water > 72, warnLabel: "Too wet!"
                ) {
                    withAnimation { engine.waterPlant() }
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
                TapButton(
                    icon: engine.activePests ? "ant.fill" : "sparkles",
                    label: engine.activePests ? "Treat!" : "Mist",
                    color: engine.activePests ? .red : .purple,
                    highlight: engine.activePests
                ) {
                    withAnimation { engine.mistOrTreat() }
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
            }
            LocationPicker(selection: $engine.location)
        }
    }

    var nextDayButton: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { engine.advance() }
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "moon.stars.fill")
                Text("Next Day").font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.1, green: 0.15, blue: 0.3),
                             Color(red: 0.22, green: 0.28, blue: 0.5)],
                    startPoint: .leading, endPoint: .trailing
                )
            )
            .cornerRadius(18)
            .shadow(color: Color(red: 0.1, green: 0.15, blue: 0.3).opacity(0.35), radius: 10, x: 0, y: 4)
        }
        .disabled(engine.showLesson || engine.isFinished || engine.isDead)
        .opacity(engine.showLesson || engine.isFinished || engine.isDead ? 0.45 : 1.0)
    }

    var deathOverlay: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()
            VStack(spacing: 22) {
                Text("🥀")
                    .font(.system(size: 70))
                Text("Your Plant Died")
                    .font(.title.bold())
                Text("Health reached 0 on day \(engine.days).\nTake better care next time!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                HStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text(deathHint)
                        .font(.footnote.bold())
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(14)

                Button {
                    withAnimation(.spring()) { engine.restart() }
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                } label: {
                    Text("🌱  Try Again")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(red: 0.22, green: 0.55, blue: 0.28))
                        .cornerRadius(16)
                }
            }
            .padding(26)
            .background(Color.white)
            .cornerRadius(28)
            .shadow(color: .black.opacity(0.2), radius: 30, x: 0, y: 10)
            .padding(.horizontal, 22)
        }
    }

    var deathHint: String {
        if engine.isOverwatered || engine.water > 75 {
            return "Too much water caused root rot. Move indoors to dry out."
        } else if engine.water < 15 {
            return "The plant dried out. Water it before levels drop below 15%."
        } else if engine.activePests {
            return "Pests went untreated for too long. Use Treat as soon as they appear."
        } else {
            return "Multiple issues combined. Watch all three stats, not just one."
        }
    }
}

struct LessonCard: View {
    let lesson: DayLesson
    let isFinished: Bool
    var onDismiss: () -> Void
    var onRestart: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.45).ignoresSafeArea()

            VStack(spacing: 22) {
                Text(lesson.emoji).font(.system(size: 64))

                VStack(spacing: 10) {
                    Text(lesson.title)
                        .font(.title3.bold())
                        .multilineTextAlignment(.center)
                    Text(lesson.body)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }

                HStack(spacing: 10) {
                    Image(systemName: "hand.point.right.fill")
                        .foregroundColor(Color(red: 0.22, green: 0.55, blue: 0.28))
                    Text(lesson.actionPrompt)
                        .font(.footnote.bold())
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(red: 0.9, green: 0.97, blue: 0.91))
                .cornerRadius(14)

                Button {
                    isFinished ? onRestart() : onDismiss()
                } label: {
                    Text(isFinished ? "🌱  Restart Simulation" : "Got it!")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(red: 0.22, green: 0.55, blue: 0.28))
                        .cornerRadius(16)
                }
            }
            .padding(26)
            .background(Color.white)
            .cornerRadius(28)
            .shadow(color: .black.opacity(0.18), radius: 30, x: 0, y: 10)
            .padding(.horizontal, 22)
        }
    }
}

struct StatPill: View {
    var icon: String; var label: String; var value: Int; var color: Color
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.caption.weight(.semibold)).foregroundColor(color)
                Text(label).font(.caption2.bold()).foregroundColor(.secondary)
            }
            Text("\(value)%").font(.title3.bold())
            ProgressView(value: Double(value), total: 100)
                .tint(color)
                .scaleEffect(x: 1, y: 1.4, anchor: .center)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.88))
        .cornerRadius(16)
        .shadow(color: color.opacity(0.12), radius: 5, x: 0, y: 2)
    }
}

struct TapButton: View {
    var icon: String; var label: String; var color: Color
    var warn: Bool = false; var warnLabel: String = ""
    var highlight: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(highlight ? color : color.opacity(0.13))
                        .frame(width: 46, height: 46)
                    Image(systemName: icon)
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundColor(highlight ? .white : color)
                }
                Text(warn ? warnLabel : label)
                    .font(.caption.bold())
                    .foregroundColor(warn ? .orange : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(0.9))
                    .shadow(color: (highlight ? color : Color.black).opacity(0.12), radius: 6, x: 0, y: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(highlight ? color.opacity(0.5) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct LocationPicker: View {
    @Binding var selection: LightLocation
    let green = Color(red: 0.22, green: 0.55, blue: 0.28)

    var body: some View {
        HStack(spacing: 0) {
            ForEach(LightLocation.allCases, id: \.self) { loc in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selection = loc }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: locIcon(for: loc)).font(.caption.weight(.semibold))
                        Text(loc.rawValue).font(.caption.bold())
                    }
                    .foregroundColor(selection == loc ? .white : .primary.opacity(0.55))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 13)
                            .fill(selection == loc ? green : Color.clear)
                            .shadow(color: selection == loc ? green.opacity(0.35) : .clear, radius: 5, x: 0, y: 2)
                    )
                }
            }
        }
        .padding(4)
        .background(Color.white.opacity(0.88))
        .cornerRadius(17)
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
    }

    func locIcon(for loc: LightLocation) -> String {
        switch loc {
        case .indoor:  return "house.fill"
        case .window:  return "window.casement"
        case .outdoor: return "tree.fill"
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.65), value: configuration.isPressed)
    }
}

struct Leaf: View {
    var size: CGFloat; var color: Color; var isLeft: Bool
    var body: some View {
        Ellipse().fill(color)
            .frame(width: size, height: size / 2)
            .rotationEffect(.degrees(isLeft ? -38 : 38))
    }
}

struct GrassView: View {
    var body: some View {
        GeometryReader { geo in
            HStack(alignment: .bottom, spacing: -2) {
                ForEach(0..<60, id: \.self) { _ in BladeOfGrass(height: .random(in: 18...42)) }
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .bottom)
        }
    }
}

struct BladeOfGrass: View {
    let height: CGFloat
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 50))
            path.addQuadCurve(to: CGPoint(x: 2, y: 50 - height), control: CGPoint(x: -5, y: 50 - height / 2))
            path.addQuadCurve(to: CGPoint(x: 4, y: 50), control: CGPoint(x: 8, y: 50 - height / 2))
        }
        .fill(Color.green.opacity(0.5))
        .frame(width: 4, height: 50)
    }
}
