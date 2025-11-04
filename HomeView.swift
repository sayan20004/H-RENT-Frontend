import SwiftUI

struct HomeView: View {
    @Binding var loggedInUser: User?
    @State private var properties: [Property] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if isLoading {
                        ProgressView()
                    } else if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    } else if properties.isEmpty {
                        Text("No properties available right now.")
                            .foregroundColor(.secondary)
                            .padding(.top, 50)
                    } else {
                        ForEach(properties) { property in
                            NavigationLink(destination: PropertyDetailView(property: property)) {
                                PropertyCardView(property: property)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Browse Properties")
            .task {
                await loadProperties()
            }
            .refreshable {
                await loadProperties()
            }
        }
    }
    
    func loadProperties() async {
        isLoading = true
        errorMessage = nil
        do {
            let response = try await APIService.shared.getAllProperties()
            self.properties = response.properties
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
