import SwiftUI

struct PlantIssue: Identifiable {
    let id = UUID()
    let name: String
    let symptom: String
    let solution: String
    let icon: String
    let color: Color
}

struct PlantClinicView: View {
    let issues = [
        PlantIssue(name: "Overwatering", symptom: "Leaves are turning yellow and wilting. Soil feels soggy.", solution: "Stop watering immediately. Ensure the pot has drainage holes and let the top 2 inches of soil dry out completely before watering again.", icon: "drop.triangle.fill", color: .blue),
        PlantIssue(name: "Underwatering", symptom: "Leaves are dry, crispy, and curling inward at the edges.", solution: "Give the plant a thorough soak. If the soil is completely completely dry, bottom-water the plant by placing the pot in a bowl of water for 30 minutes.", icon: "sun.dust.fill", color: .orange),
        PlantIssue(name: "Sunburn", symptom: "Pale, bleached, or scorched brown patches on the leaves.", solution: "Move the plant away from direct, harsh sunlight. Most indoor plants prefer bright, indirect light.", icon: "sun.max.trianglebadge.exclamationmark.fill", color: .red),
        PlantIssue(name: "Pest Infestation", symptom: "Tiny webs, sticky residue, or visible small insects on the underside of leaves.", solution: "Isolate the plant immediately. Wipe leaves down with a damp cloth and treat with neem oil or mild insecticidal soap.", icon: "ladybug.fill", color: .purple)
    ]
    
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 44, height: 44)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            
                            Image(systemName: "chevron.left")
                                .font(.title3.weight(.medium))
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Spacer()
                    
                    Text("Plant Clinic")
                        .font(.headline)
                    
                    Spacer()
                    
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 16)
                
                ScrollView {
                    VStack(spacing: 16) {
                        Text("Identify what's wrong with your plant and learn how to fix it.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top, 10)
                        
                        ForEach(issues) { issue in
                            IssueCard(issue: issue)
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct IssueCard: View {
    var issue: PlantIssue
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(issue.color.opacity(0.15))
                            .frame(width: 44, height: 44)
                        Image(systemName: issue.icon)
                            .foregroundColor(issue.color)
                            .font(.title3)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(issue.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(issue.symptom)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(isExpanded ? nil : 1)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.white)
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                    HStack {
                        Image(systemName: "cross.case.fill")
                            .foregroundColor(.green)
                        Text("Solution")
                            .font(.subheadline.bold())
                            .foregroundColor(.primary)
                    }
                    .padding(.top, 8)
                    
                    Text(issue.solution)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal)
                .padding(.bottom)
                .background(Color.white)
            }
        }
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        .padding(.horizontal)
    }
}

#Preview {
    PlantClinicView()
}
