import SwiftUI
import PhotosUI

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
    @State private var status: PropertyStatus = .active
    
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var selectedImage: Image?
    
    @State private var errorMessage: String?
    @State private var isUploading: Bool = false
    
    private let appGreen = Color(red: 62/255, green: 178/255, blue: 82/255)
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Property Details")) {
                    TextField("Title", text: $title)
                    TextField("Address", text: $address)
                    TextEditor(text: $description)
                        .frame(height: 100)
                }
                
                Section(header: Text("Property Image")) {
                    VStack(alignment: .leading) {
                        if let selectedImage {
                            selectedImage
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 200)
                                .cornerRadius(10)
                                .clipped()
                        } else if !imageURL.isEmpty {
                            AsyncImage(url: URL(string: imageURL)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 200)
                                    .cornerRadius(10)
                                    .clipped()
                            } placeholder: {
                                ProgressView()
                                    .frame(height: 200)
                            }
                        }
                        
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                            Text(selectedImage == nil ? "Select Image" : "Change Image")
                        }
                        .onChange(of: selectedPhotoItem) {
                            Task {
                                if let data = try? await selectedPhotoItem?.loadTransferable(type: Data.self) {
                                    self.selectedImageData = data
                                    if let uiImage = UIImage(data: data) {
                                        self.selectedImage = Image(uiImage: uiImage)
                                    }
                                }
                            }
                        }
                    }
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
                    Picker("Status", selection: $status) {
                        Text(PropertyStatus.active.displayName).tag(PropertyStatus.active)
                        Text(PropertyStatus.hidden.displayName).tag(PropertyStatus.hidden)
                    }
                    .pickerStyle(.segmented)
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                if isUploading {
                    Section {
                        HStack {
                            ProgressView()
                            Text("Uploading, please wait...")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Button(isUploading ? "Saving..." : "Save Property") {
                    saveProperty()
                }
                .tint(appGreen)
                .disabled(isUploading)
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
                    status = property.status
                }
            }
        }
    }
    
    func saveProperty() {
        Task {
            isUploading = true
            errorMessage = nil
            
            var finalImageURL = self.imageURL
            
            if let imageData = self.selectedImageData {
                do {
                    let response = try await APIService.shared.uploadImage(imageData: imageData)
                    finalImageURL = response.imageUrl
                } catch {
                    self.errorMessage = "Image upload failed: \(error.localizedDescription)"
                    isUploading = false
                    return
                }
            }
            
            guard !finalImageURL.isEmpty else {
                self.errorMessage = "Please select an image."
                isUploading = false
                return
            }
            
            do {
                if let property = propertyToEdit {
                    let request = UpdatePropertyRequest(
                        title: title,
                        description: description,
                        address: address,
                        images: [finalImageURL],
                        price: price,
                        pricingFrequency: pricingFrequency,
                        allowBargaining: allowBargaining,
                        status: status
                    )
                    _ = try await APIService.shared.updateProperty(id: property.id, requestBody: request)
                } else {
                    _ = try await APIService.shared.createProperty(
                        title: title,
                        description: description,
                        address: address,
                        images: [finalImageURL],
                        price: price,
                        pricingFrequency: pricingFrequency,
                        allowBargaining: allowBargaining
                    )
                }
                isUploading = false
                onSave()
                dismiss()
            } catch {
                self.errorMessage = error.localizedDescription
                isUploading = false
            }
        }
    }
}
