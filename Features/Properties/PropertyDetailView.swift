import SwiftUI

struct PropertyDetailView: View {
    let property: Property
    
    @State private var errorMessage: String?
    @State private var successMessage: String?
    
    private let appGreen = Color(red: 104/255, green: 222/255, blue: 122/255)
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                AsyncImage(url: URL(string: property.images.first ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 250)
                        .clipped()
                } placeholder: {
                    Rectangle()
                        .fill(Color(white: 0.1))
                        .frame(height: 250)
                        .overlay(
                            Image(systemName: "house.fill")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        )
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(property.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(property.address)
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Price")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("$\(String(format: "%.2f", property.price)) / \(property.pricingFrequency.displayName)")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(appGreen)
                        }
                        
                        Spacer()
                        
                        if property.allowBargaining {
                            Text("Bargaining Allowed")
                                .font(.caption)
                                .padding(8)
                                .background(appGreen.opacity(0.1))
                                .foregroundColor(appGreen)
                                .cornerRadius(8)
                        }
                    }
                    
                    Divider()

                    Text("Description")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text(property.description)
                        .font(.body)
                    
                    Divider()
                    
                    Text("Owner")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("\(property.owner.firstName ?? "Unknown") \(property.owner.lastName ?? "Owner")")
                        .font(.body)
                    Text(property.owner.email ?? "No email provided")
                        .font(.subheadline)
                        .tint(appGreen)
                    
                    Spacer(minLength: 40)
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    
                    if let successMessage = successMessage {
                        Text(successMessage)
                            .foregroundColor(appGreen)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }

                    Button {
                        requestRental()
                    } label: {
                        Text("Rent Now")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(appGreen)
                            .foregroundColor(.black)
                            .cornerRadius(14)
                    }
                    .disabled(successMessage != nil)
                    
                }
                .padding()
            }
        }
        .navigationTitle("Property Details")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
    
    func requestRental() {
        Task {
            do {
                _ = try await APIService.shared.createRentalRequest(propertyId: property.id)
                self.successMessage = "Rental request sent successfully!"
                self.errorMessage = nil
            } catch {
                self.errorMessage = error.localizedDescription
                self.successMessage = nil
            }
        }
    }
}
