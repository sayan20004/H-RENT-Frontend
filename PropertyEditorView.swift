import SwiftUI

struct PropertyEditorView: View {
    @Environment(\.dismiss) var dismiss
    
    var propertyToEdit: Property?
    var onSave: () -> Void
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var address: String = ""
    @State private var imageURL: String = ""
    @State private var price: Double = 0
    @State private var pricingFrequency: PricingFrequency = .monthly
    @State private var allowBargaining: Bool = false
    @State private var isAvailable: Bool = true
    
    @State private var errorMessage: String?
    
    private let appGreen = Color(red: 62/255, green: 178/255, blue: 82/255)
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Property Details")) {
                    TextField("Title", text: $title)
                    TextField("Address", text: $address)
                    TextField("Image URL", text: $imageURL)
                    TextEditor(text: $description)
                        .frame(height: 100)
                }
                
                Section(header: Text("Pricing")) {
                    TextField("Price", value: $price, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                    
                    Picker("Frequency", selection: $pricingFrequency) {
                        ForEach(PricingFrequency.allCases) { freq in
                            Text(freq.displayName).tag(freq)
                        }
                    }
                }
                
                Section(header: Text("Options")) {
                    Toggle("Allow Bargaining", isOn: $allowBargaining)
                    if propertyToEdit != nil {
                        Toggle("Is Available", isOn: $isAvailable)
                    }
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                Button("Save Property") {
                    saveProperty()
                }
                .tint(appGreen)
            }
            .navigationTitle(propertyToEdit == nil ? "Create Property" : "Edit Property")
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
            .onAppear {
                if let property = propertyToEdit {
                    title = property.title
                    description = property.description
                    address = property.address
                    imageURL = property.images.first ?? ""
                    price = property.price
                    pricingFrequency = property.pricingFrequency
                    allowBargaining = property.allowBargaining
                    isAvailable = property.isAvailable
                }
            }
        }
    }
    
    func saveProperty() {
        Task {
            do {
                if let property = propertyToEdit {
                    let request = UpdatePropertyRequest(
                        title: title,
                        description: description,
                        address: address,
                        images: [imageURL],
                        price: price,
                        pricingFrequency: pricingFrequency,
                        allowBargaining: allowBargaining,
                        isAvailable: isAvailable
                    )
                    _ = try await APIService.shared.updateProperty(id: property.id, requestBody: request)
                } else {
                    _ = try await APIService.shared.createProperty(
                        title: title,
                        description: description,
                        address: address,
                        images: [imageURL],
                        price: price,
                        pricingFrequency: pricingFrequency,
                        allowBargaining: allowBargaining
                    )
                }
                onSave()
                dismiss()
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
