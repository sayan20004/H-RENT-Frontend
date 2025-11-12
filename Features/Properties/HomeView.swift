import SwiftUI

enum SortOption: String, CaseIterable, Identifiable {
    case latest = "createdAtDesc"
    case priceAsc = "priceAsc"
    case priceDesc = "priceDesc"
    
    var id: Self { self }
    
    var displayName: String {
        switch self {
        case .latest:
            return "Latest"
        case .priceAsc:
            return "Price: Low to High"
        case .priceDesc:
            return "Price: High to Low"
        }
    }
}

struct HomeView: View {
    @Binding var loggedInUser: User?
    @State private var properties: [Property] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var sortBy: SortOption = .latest
    
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Sort By", selection: $sortBy) {
                            ForEach(SortOption.allCases) { option in
                                Text(option.displayName).tag(option)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .task {
                await loadProperties()
            }
            .refreshable {
                await loadProperties()
            }
            .onChange(of: sortBy) {
                Task {
                    await loadProperties()
                }
            }
        }
    }
    
    func loadProperties() async {
        isLoading = true
        errorMessage = nil
        do {
            let response = try await APIService.shared.getAllProperties(sortBy: sortBy.rawValue)
            self.properties = response.properties
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
