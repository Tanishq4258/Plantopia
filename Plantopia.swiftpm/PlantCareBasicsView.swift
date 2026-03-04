import SwiftUI

struct CareTip: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let description: String
    let icon: String
    let color: Color
    let tag: String
}

struct PlantCareBasicsView: View {
    @Environment(\.dismiss) var dismiss
    
    let proTips = [
        "When in doubt, don't water. It's easier to fix a thirsty plant than a drowned one!",
        "Dust your leaves! A dusty leaf can't 'breathe' or absorb sunlight properly.",
        "Rotate your pots 90° every week so your plant grows straight instead of leaning.",
        "Use room temperature water. Ice-cold water can shock sensitive tropical roots.",
        "Always check for drainage holes. Sitting in water is the #1 cause of root rot."
    ]
    
    @State private var currentTipIndex = 0
    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
    let tips = [
        CareTip(title: "The Light Rule", subtitle: "It's all about the 'View'", description: "Direct sun means the plant 'sees' the sun. Indirect means it sees the sky. Low light means it's in a shady corner.", icon: "sun.max.fill", color: .orange, tag: "LIGHT"),
        CareTip(title: "The Finger Test", subtitle: "Forget the calendar", description: "Poke the soil 2 inches deep. If it feels dry, water it. If it's damp, walk away.", icon: "drop.fill", color: .blue, tag: "WATER"),
        CareTip(title: "Leaf Language", subtitle: "Your plant is talking", description: "Yellow leaves? Too much water. Crispy brown edges? Too dry. Drooping? Needs a drink.", icon: "leaf.fill", color: .green, tag: "SIGNS"),
        CareTip(title: "The Jungle Vibe", subtitle: "Humidity is key", description: "Tropical plants hate dry AC air. Group them together or keep them in the bathroom.", icon: "cloud.fog.fill", color: .cyan, tag: "AIR")
    ]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemGray6).ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button { dismiss() } label: {
                        ZStack {
                            Circle().fill(Color.white).frame(width: 44, height: 44)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            Image(systemName: "chevron.left")
                                .font(.title3.weight(.medium)).foregroundColor(.primary)
                        }
                    }
                    Spacer()
                    Text("Care Basics").font(.headline)
                    Spacer()
                    Circle().fill(Color.clear).frame(width: 44, height: 44)
                }
                .padding(.horizontal).padding(.top, 8).padding(.bottom, 16)
                
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(spacing: 8) {
                            Text("Plant Parenting 101")
                                .font(.system(.title2, design: .rounded).bold())
                            Text("Master these 4 skills to keep your green friends happy.")
                                .font(.subheadline).foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 10)
                        
                        ForEach(tips) { tip in
                            CareCard(tip: tip)
                        }
                    }
                    
                    .padding(.bottom, 140)
                }
            }
            
            HStack(spacing: 15) {
                Text("💡")
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("PRO TIP")
                        .font(.caption.bold())
                        .foregroundColor(.orange)
                    
                    Text(proTips[currentTipIndex])
                        .font(.footnote)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                        .id(currentTipIndex)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .bottom)),
                            removal: .opacity.combined(with: .move(edge: .top))
                        ))
                }
            }
            .padding(20)
            .background(
                BlurView(style: .systemThinMaterialLight)
                    .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
            )
           
            .overlay(
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 20)
            .padding(.bottom, 20) // Floating effect
            .onReceive(timer) { _ in
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    currentTipIndex = (currentTipIndex + 1) % proTips.count
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

struct CareCard: View {
    let tip: CareTip
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(tip.tag).font(.caption2.bold()).padding(.horizontal, 8).padding(.vertical, 4)
                    .background(tip.color.opacity(0.2)).foregroundColor(tip.color).cornerRadius(5)
                Spacer()
                Image(systemName: tip.icon).foregroundColor(tip.color).font(.title3)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(tip.title).font(.headline)
                Text(tip.subtitle).font(.subheadline).italic().foregroundColor(.secondary)
            }
            Text(tip.description).font(.footnote).foregroundColor(.primary.opacity(0.8)).lineSpacing(4)
        }
        .padding().background(Color.white).cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5).padding(.horizontal)
    }
}

#Preview {
    PlantCareBasicsView()
}
