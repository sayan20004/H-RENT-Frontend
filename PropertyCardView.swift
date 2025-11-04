import SwiftUI

struct PropertyCardView: View {
    let property: Property
    
    private let appGreen = Color(red: 62/255, green: 178/255, blue: 82/255)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AsyncImage(url: URL(string: property.images.first ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 180)
                    .clipped()
            } placeholder: {
                Rectangle()
                    .fill(Color(.secondarySystemBackground))
                    .frame(height: 180)
                    .overlay(
                        Image(systemName: "house.fill")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                    )
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(property.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(property.address)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack {
                    Text("$\(String(format: "%.2f", property.price))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(appGreen)
                    
                    Text("/ \(property.pricingFrequency.displayName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.separator).opacity(0.5), lineWidth: 1)
        )
    }
}
