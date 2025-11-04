import SwiftUI

struct OwnerDashboardView: View {
    
    @Binding var loggedInUser: User?
    
    @State private var myProperties: [Property] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var isShowingEditor = false
    @State private var propertyToEdit: Property?
    
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
                    } else if myProperties.isEmpty {
                        Text("You haven't listed any properties yet.")
                            .foregroundColor(.secondary)
                            .padding(.top, 50)
                    } else {
                        ForEach(myProperties) { property in
                            PropertyCardView(property: property)
                                .onTapGesture {
                                    self.propertyToEdit = property
                                    self.isShowingEditor = true
                                }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("My Properties")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        self.propertyToEdit = nil
                        self.isShowingEditor = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .task {
                await loadMyProperties()
            }
            .sheet(isPresented: $isShowingEditor) {
                PropertyEditorView(propertyToEdit: propertyToEdit) {
                    Task {
                        await loadMyProperties()
                    }
                }
            }
        }
    }
    
    func loadMyProperties() async {
        isLoading = true
        errorMessage = nil
        do {
            let response = try await APIService.shared.getMyProperties()
            self.myProperties = response.properties
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
