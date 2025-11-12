import SwiftUI

enum PropertyFilter: String, CaseIterable, Identifiable {
    case active
    case hidden
    case all
    
    var id: Self { self }
    var displayName: String { self.rawValue.capitalized }
}

struct OwnerDashboardView: View {
    
    @Binding var loggedInUser: User?
    
    @State private var myProperties: [Property] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var isShowingEditor = false
    @State private var propertyToEdit: Property?
    
    @State private var propertyFilter: PropertyFilter = .active
    
    private var filteredProperties: [Property] {
        switch propertyFilter {
        case .active:
            return myProperties.filter { $0.status == .active }
        case .hidden:
            return myProperties.filter { $0.status == .hidden }
        case .all:
            return myProperties.filter { $0.status != .deleted }
        }
    }
    
    private var deletedProperties: [Property] {
        myProperties.filter { $0.status == .deleted }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Picker("Filter Properties", selection: $propertyFilter) {
                    ForEach(PropertyFilter.allCases) { filter in
                        Text(filter.displayName).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.bottom, 10)
                
                ScrollView {
                    if isLoading {
                        ProgressView()
                            .padding(.top, 50)
                    } else if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    } else if myProperties.isEmpty {
                        Text("You haven't listed any properties yet.")
                            .foregroundColor(.secondary)
                            .padding(.top, 50)
                    } else {
                        LazyVStack(spacing: 20) {
                            ForEach(filteredProperties) { property in
                                propertyCard(property)
                            }
                            
                            if propertyFilter == .all && !deletedProperties.isEmpty {
                                Section(header: Text("Deleted Properties").font(.headline).padding(.top)) {
                                    ForEach(deletedProperties) { property in
                                        propertyCard(property)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
            }
            .padding(.top)
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
            .refreshable {
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
    
    @ViewBuilder
    func propertyCard(_ property: Property) -> some View {
        PropertyCardView(property: property)
            .contentShape(Rectangle())
            .onTapGesture {
                if property.status != .deleted {
                    self.propertyToEdit = property
                    self.isShowingEditor = true
                }
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                if property.status != .deleted {
                    Button(role: .destructive) {
                        Task { await updateStatus(for: property, status: .deleted) }
                    } label: {
                        Label("Delete", systemImage: "trash.fill")
                    }
                    
                    if property.status == .hidden {
                        Button {
                            Task { await updateStatus(for: property, status: .active) }
                        } label: {
                            Label("Unhide", systemImage: "eye.fill")
                        }
                        .tint(.green)
                    } else {
                        Button {
                            Task { await updateStatus(for: property, status: .hidden) }
                        } label: {
                            Label("Hide", systemImage: "eye.slash.fill")
                        }
                        .tint(.yellow)
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
    
    func updateStatus(for property: Property, status: PropertyStatus) async {
        do {
            if status == .deleted {
                let response = try await APIService.shared.deleteProperty(id: property.id)
                if response.success {
                    await loadMyProperties()
                }
            } else {
                let response = try await APIService.shared.updatePropertyStatus(id: property.id, status: status)
                if response.success {
                    await loadMyProperties()
                }
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
