import SwiftUI


struct SpecificPlant: Identifiable {
    let id = UUID()
    let name: String
    let scientificName: String
    let waterNeeds: String
    let sunNeeds: String
    let funFact: String
    let imageName: String
    let placeholderColor: Color
}

struct PlantCategory: Identifiable {
    let id = UUID()
    let name: String
    let shortDescription: String
    let icon: String
    let color: Color
    let plants: [SpecificPlant]
}



struct PlantCategoriesView: View {
    
    
    let categories = [
        PlantCategory(
            name: "The Indestructibles",
            shortDescription: "Tough potted plants that can survive forgetful waterers.",
            icon: "shield.fill", color: .green,
            plants: [
                SpecificPlant(name: "Snake Plant", scientificName: "Sansevieria", waterNeeds: "Every 2-3 weeks", sunNeeds: "Low to Bright", funFact: "It converts CO2 into oxygen at night, making it a perfect bedroom plant!", imageName: "snake_plant", placeholderColor: .green),
                SpecificPlant(name: "ZZ Plant", scientificName: "Zamioculcas zamiifolia", waterNeeds: "Every 2-3 weeks", sunNeeds: "Low to Bright", funFact: "It stores water in bulb-like roots under the soil, so it rarely needs watering.", imageName: "zz_plant", placeholderColor: .mint),
                SpecificPlant(name: "Aloe Vera", scientificName: "Aloe barbadensis", waterNeeds: "Every 3 weeks", sunNeeds: "Bright, direct", funFact: "The gel inside its thick leaves can be used to soothe minor burns and cuts.", imageName: "aloe_vera", placeholderColor: .teal)
            ]
        ),
        PlantCategory(
            name: "Low-Light Lovers",
            shortDescription: "Perfect for desks, bathrooms, and shady corners.",
            icon: "moon.stars.fill", color: .indigo,
            plants: [
                SpecificPlant(name: "Pothos", scientificName: "Epipremnum aureum", waterNeeds: "Every 1-2 weeks", sunNeeds: "Low, indirect", funFact: "Known as 'Devil's Ivy' because it stays green even when kept in near darkness.", imageName: "pothos", placeholderColor: .indigo),
                SpecificPlant(name: "Cast Iron Plant", scientificName: "Aspidistra elatior", waterNeeds: "Every 1-2 weeks", sunNeeds: "Low", funFact: "Earned its name in the 1800s for surviving the harsh fumes of gas lamps.", imageName: "cast_iron", placeholderColor: .purple),
                SpecificPlant(name: "Parlor Palm", scientificName: "Chamaedorea elegans", waterNeeds: "Every 1-2 weeks", sunNeeds: "Low to Medium", funFact: "A slow-growing miniature palm that stays small enough for a tabletop.", imageName: "palm", placeholderColor: .blue)
            ]
        ),
        PlantCategory(
            name: "Pet-Safe Plants",
            shortDescription: "100% non-toxic for curious cats and dogs.",
            icon: "pawprint.fill", color: .orange,
            plants: [
                SpecificPlant(name: "Spider Plant", scientificName: "Chlorophytum comosum", waterNeeds: "Weekly", sunNeeds: "Bright, indirect", funFact: "Grows tiny 'babies' on long stems that you can snip off and plant!", imageName: "spider_plant", placeholderColor: .orange),
                SpecificPlant(name: "Boston Fern", scientificName: "Nephrolepis exaltata", waterNeeds: "Weekly", sunNeeds: "Medium, indirect", funFact: "A classic houseplant that looks beautiful hanging in a small basket.", imageName: "boston", placeholderColor: .yellow),
                SpecificPlant(name: "Watermelon Peperomia", scientificName: "Peperomia argyreia", waterNeeds: "Every 1-2 weeks", sunNeeds: "Medium, indirect", funFact: "Its rounded leaves look exactly like tiny, striped watermelons!", imageName: "watermelon", placeholderColor: .red)
            ]
        ),
        PlantCategory(
            name: "Fresh Air Providers",
            shortDescription: "Leafy friends known for purifying indoor air.",
            icon: "wind", color: .cyan,
            plants: [
                SpecificPlant(name: "Peace Lily", scientificName: "Spathiphyllum", waterNeeds: "Weekly", sunNeeds: "Low to Medium", funFact: "It will dramatically droop its leaves when thirsty, but perks right back up.", imageName: "lily", placeholderColor: .cyan),
                SpecificPlant(name: "Rubber Tree", scientificName: "Ficus elastica", waterNeeds: "Every 1-2 weeks", sunNeeds: "Bright, indirect", funFact: "Its sticky white sap was used to make bouncy rubber centuries ago.", imageName: "rubber_tree", placeholderColor: .teal),
                SpecificPlant(name: "Areca Palm", scientificName: "Dypsis lutescens", waterNeeds: "Weekly", sunNeeds: "Bright, indirect", funFact: "Acts as a natural humidifier, pumping moisture back into dry air.", imageName: "areca_palm", placeholderColor: .blue)
            ]
        )
    ]
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // header
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
                    Text("Plant Categories").font(.headline)
                    Spacer()
                    Circle().fill(Color.clear).frame(width: 44, height: 44)
                }
                .padding(.horizontal).padding(.top, 8).padding(.bottom, 16)
                
                ScrollView {
                    VStack(spacing: 16) {
                        Text("Tap a category to discover the perfect small plants for your home.")
                            .font(.subheadline).foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal)
                        
                        ForEach(categories) { category in
                            NavigationLink(destination: CategoryDetailView(category: category)) {
                                SimplifiedCategoryCard(category: category)
                            }
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct SimplifiedCategoryCard: View {
    var category: PlantCategory
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16).fill(category.color.opacity(0.15))
                    .frame(width: 60, height: 60)
                Image(systemName: category.icon).font(.title).foregroundColor(category.color)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name).font(.headline).foregroundColor(.primary)
                Text(category.shortDescription).font(.caption).foregroundColor(.secondary)
                    .multilineTextAlignment(.leading).lineLimit(2)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundColor(Color(.systemGray3)).font(.body.weight(.bold))
        }
        .padding().background(Color.white).cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2).padding(.horizontal)
    }
}

struct CategoryDetailView: View {
    var category: PlantCategory
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
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
                    Text(category.name).font(.headline)
                    Spacer()
                    Circle().fill(Color.clear).frame(width: 44, height: 44)
                }
                .padding(.horizontal).padding(.top, 8).padding(.bottom, 16)
                
                ScrollView {
                    VStack(spacing: 24) {
                        ForEach(category.plants) { plant in
                            PlantDetailCard(plant: plant)
                        }
                    }
                    .padding(.vertical, 10).padding(.bottom, 40)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct PlantDetailCard: View {
    var plant: SpecificPlant
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(plant.imageName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 180)
                .clipped()
                .background(plant.placeholderColor.opacity(0.1))
            
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(plant.name).font(.title3.bold())
                    Text(plant.scientificName).font(.caption).foregroundColor(.secondary).italic()
                }
                
                Divider()
                
                HStack(spacing: 20) {
                    HStack(spacing: 6) {
                        Image(systemName: "drop.fill").foregroundColor(.blue)
                        Text(plant.waterNeeds).font(.caption.bold())
                    }
                    HStack(spacing: 6) {
                        Image(systemName: "sun.max.fill").foregroundColor(.yellow)
                        Text(plant.sunNeeds).font(.caption.bold())
                    }
                }
                
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "sparkles").foregroundColor(.yellow)
                    Text(plant.funFact).font(.subheadline).foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding()
            .background(Color.white)
        }
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
        .padding(.horizontal)
    }
}

#Preview {
    PlantCategoriesView()
}
