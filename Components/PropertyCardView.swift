import SwiftUI

struct PropertyCardView: View {
    let property: Property
    
    private let appGreen = Color(red: 104/255, green: 222/255, blue: 122/255)

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
                    .fill(Color(white: 0.1))
                    .frame(height: 180)
                    .overlay(
                        Image(systemName: "house.fill")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    )
            }
            .overlay(alignment: .topLeading) {
                if property.status != .active {
                    Text(property.status.displayName)
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(property.status == .hidden ? .yellow : .red)
                        .foregroundColor(property.status == .hidden ? .black : .white)
                        .cornerRadius(6)
                        .padding(8)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(property.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(property.address)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                
                HStack {
                    Text("$\(String(format: "%.2f", property.price))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(appGreen)
                    
                    Text("/ \(property.pricingFrequency.displayName)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                }
            }
            .padding()
        }
        .background(Color.black)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

