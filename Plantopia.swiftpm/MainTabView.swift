import SwiftUI


struct MainTabView: View {
    let accentGreen = Color(red: 88/255, green: 141/255, blue: 85/255)
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    @State private var showSplash = true
    @State private var showOnboarding = false

    var body: some View {
        ZStack {
            TabView {
                HomeLearnView()
                    .tabItem { Label("Learn", systemImage: "book.pages.fill") }
                GameView()
                    .tabItem { Label("Simulate", systemImage: "leaf.fill") }
            }
            .tint(accentGreen)

            if showSplash {
                SplashScreenView {
                    withAnimation(.easeInOut(duration: 0.5)) { showSplash = false }
                    if !hasSeenOnboarding { showOnboarding = true }
                }
                .zIndex(2)
                .transition(.opacity)
            }
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView {
                hasSeenOnboarding = true
                showOnboarding = false
            }
        }
    }
}


struct SplashScreenView: View {
    var onFinish: () -> Void

    @State private var logoScale: CGFloat = 0.4
    @State private var logoOpacity: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var titleOffset: CGFloat = 24
    @State private var taglineOpacity: Double = 0

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.88, green: 0.97, blue: 0.9),
                    Color(red: 0.75, green: 0.92, blue: 0.78)
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("🌱")
                    .font(.system(size: 90))
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                VStack(spacing: 8) {
                    Text("Plant Lab")
                        .font(.system(.largeTitle, design: .rounded).bold())
                        .foregroundColor(Color(red: 0.15, green: 0.42, blue: 0.2))
                        .opacity(titleOpacity)
                        .offset(y: titleOffset)

                    Text("Learn. Grow. Thrive.")
                        .font(.subheadline)
                        .foregroundColor(Color(red: 0.3, green: 0.55, blue: 0.35))
                        .opacity(taglineOpacity)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.62).delay(0.15)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.5)) {
                titleOpacity = 1.0
                titleOffset = 0
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.78)) {
                taglineOpacity = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                onFinish()
            }
        }
    }
}


struct OnboardingPage: Identifiable {
    let id = UUID()
    let emoji: String
    let title: String
    let subtitle: String
    let color: Color
}


struct OnboardingView: View {
    var onFinish: () -> Void
    @State private var currentPage = 0

    let pages = [
        OnboardingPage(
            emoji: "🌱",
            title: "Welcome to Plant Lab",
            subtitle: "Your interactive guide to understanding plant care. Learn the science, then put it into practice.",
            color: Color(red: 0.22, green: 0.58, blue: 0.28)
        ),
        OnboardingPage(
            emoji: "📚",
            title: "Learn First",
            subtitle: "Browse plant categories, master watering and light basics, and diagnose sick plants in the Plant Clinic.",
            color: Color(red: 0.3, green: 0.5, blue: 0.85)
        ),
        OnboardingPage(
            emoji: "🎮",
            title: "Then Simulate",
            subtitle: "Grow a virtual plant over 12 days. The simulation teaches through real consequences — overwatering, pests, and drought.",
            color: Color(red: 0.65, green: 0.38, blue: 0.82)
        ),
        OnboardingPage(
            emoji: "🌸",
            title: "Grow with Confidence",
            subtitle: "Every lesson you learn here applies to real plants at home. Ready to start?",
            color: Color(red: 0.88, green: 0.48, blue: 0.18)
        )
    ]

    var body: some View {
        ZStack {
            pages[currentPage].color
                .opacity(0.1)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.4), value: currentPage)

            VStack(spacing: 0) {
                Spacer()

                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        VStack(spacing: 30) {
                            Text(page.emoji)
                                .font(.system(size: 88))
                                .shadow(color: page.color.opacity(0.25), radius: 18)

                            VStack(spacing: 12) {
                                Text(page.title)
                                    .font(.system(.title2, design: .rounded).bold())
                                    .multilineTextAlignment(.center)

                                Text(page.subtitle)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(3)
                                    .padding(.horizontal, 28)
                            }
                        }
                        .padding(.horizontal)
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 380)

                
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { i in
                        Capsule()
                            .fill(i == currentPage
                                  ? pages[currentPage].color
                                  : Color.gray.opacity(0.25))
                            .frame(width: i == currentPage ? 26 : 8, height: 8)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                    }
                }
                .padding(.top, 28)

                Spacer()

                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    if currentPage < pages.count - 1 {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            currentPage += 1
                        }
                    } else {
                        onFinish()
                    }
                } label: {
                    HStack(spacing: 10) {
                        Text(currentPage < pages.count - 1 ? "Next" : "Start Growing 🌿")
                            .font(.headline)
                        if currentPage < pages.count - 1 {
                            Image(systemName: "arrow.right")
                                .font(.body.weight(.semibold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(
                        LinearGradient(
                            colors: [pages[currentPage].color, pages[currentPage].color.opacity(0.72)],
                            startPoint: .leading, endPoint: .trailing
                        )
                        .animation(.easeInOut(duration: 0.4), value: currentPage)
                    )
                    .cornerRadius(18)
                    .shadow(color: pages[currentPage].color.opacity(0.38), radius: 12, x: 0, y: 4)
                    .animation(.easeInOut(duration: 0.3), value: currentPage)
                }
                .padding(.horizontal, 30)
                .buttonStyle(ScaleButtonStyle())

                Button { onFinish() } label: {
                    Text("Skip")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 14)
                }
            }
            .padding(.bottom, 20)
        }
    }
}

//landing pg
struct HomeLearnView: View {
    let accentGreen = Color(red: 88/255, green: 141/255, blue: 85/255)
    @AppStorage("playerRole") private var playerRole = "Gardener"

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6).ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("\(timeOfDayGreeting()), \(playerRole)")
                                .font(.system(.title2, design: .rounded))
                                .foregroundColor(.secondary)
                            Text("Ready to grow?")
                                .font(.system(.largeTitle, design: .rounded).bold())
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)

                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Plant Lab Active")
                                    .font(.caption.bold())
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(accentGreen.opacity(0.1))
                                    .foregroundColor(accentGreen)
                                    .cornerRadius(8)
                                Spacer()
                                Text("🌿").font(.title2)
                            }
                            Text("Your Companion in Plant Care").font(.headline)
                            Text("Practice your skills in the Simulator or study plant health in the modules below.")
                                .font(.subheadline).foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(24)
                        .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 4)
                        .padding(.horizontal)

                        VStack(spacing: 16) {
                            Text("Learning Modules")
                                .font(.system(.title3, design: .rounded).bold())
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)

                            NavigationLink(destination: PlantClinicView()) {
                                MenuCardView(title: "Plant Clinic", subtitle: "Identify and cure plant sickness", icon: "cross.case.fill", iconColor: .red)
                            }
                            NavigationLink(destination: PlantCategoriesView()) {
                                MenuCardView(title: "Plant Categories", subtitle: "Explore different types of plants", icon: "square.grid.2x2.fill", iconColor: accentGreen)
                            }
                            NavigationLink(destination: PlantCareBasicsView()) {
                                MenuCardView(title: "Care Basics", subtitle: "Master lighting, soil, and watering", icon: "drop.fill", iconColor: .blue)
                            }
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
    }

    func timeOfDayGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }
}


struct MenuCardView: View {
    var title: String
    var subtitle: String
    var icon: String
    var iconColor: Color

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().fill(iconColor.opacity(0.1)).frame(width: 54, height: 54)
                Image(systemName: icon).font(.title3).foregroundColor(iconColor)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline).foregroundColor(.primary)
                Text(subtitle).font(.caption).foregroundColor(.secondary).multilineTextAlignment(.leading)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(Color(.systemGray4))
                .font(.system(size: 14, weight: .bold))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(22)
        .shadow(color: iconColor.opacity(0.08), radius: 8, x: 0, y: 3)
        .padding(.horizontal)
    }
}
