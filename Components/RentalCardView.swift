import SwiftUI

struct RentalCardView: View {
    let rental: Rental
    
    private let appGreen = Color(red: 62/255, green: 178/255, blue: 82/255)

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: rental.property.images.first ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .cornerRadius(10)
            } placeholder: {
                Rectangle()
                    .fill(Color(.secondarySystemBackground))
                    .frame(width: 80, height: 80)
                    .cornerRadius(10)
                    .overlay(Image(systemName: "house.fill").foregroundColor(.secondary))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(rental.property.title)
                    .font(.headline)
                    .lineLimit(1)
                
                if let frequency = rental.property.pricingFrequency {
                    Text("$\(String(format: "%.2f", rental.property.price ?? 0.0)) / \(frequency.displayName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    Text("$\(String(format: "%.2f", rental.property.price ?? 0.0))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(rental.status.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(rental.status.color.opacity(0.1))
                    .foregroundColor(rental.status.color)
                    .cornerRadius(6)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.separator).opacity(0.5), lineWidth: 1)
        )
    }
}

