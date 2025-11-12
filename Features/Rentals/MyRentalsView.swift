import SwiftUI

struct MyRentalsView: View {
    @State private var rentals: [Rental] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    private let appGreen = Color(red: 62/255, green: 178/255, blue: 82/255)

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    if isLoading {
                        ProgressView()
                    } else if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    } else if rentals.isEmpty {
                        Text("You have not made any rental requests.")
                            .foregroundColor(.secondary)
                            .padding(.top, 50)
                    } else {
                        ForEach($rentals) { $rental in
                            VStack(spacing: 0) {
                                RentalCardView(rental: rental)
                                
                                HStack {
                                    if rental.status == .pending {
                                        Button("Cancel Request") {
                                            updateStatus(for: $rental, to: .cancelled)
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.red)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                    } else if rental.status == .accepted {
                                        Button("Request Cancellation") {
                                            updateStatus(for: $rental, to: .cancellationRequested)
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                    }
                                    
                                    if rental.status == .accepted || rental.status == .cancellationRequested {
                                        NavigationLink(destination: ChatNavigator(rentalId: rental.id)) {
                                            Text("Contact Owner")
                                                .padding()
                                                .frame(maxWidth: .infinity)
                                                .background(appGreen)
                                                .foregroundColor(.white)
                                                .cornerRadius(10)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("My Rentals")
            .task {
                await loadMyRentals()
            }
            .refreshable {
                 await loadMyRentals()
            }
        }
    }
    
    func loadMyRentals() async {
        isLoading = true
        errorMessage = nil
        do {
            let response = try await APIService.shared.getMyRentalRequests()
            self.rentals = response.rentals
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func updateStatus(for rental: Binding<Rental>, to newStatus: RentalStatus) {
        Task {
            do {
                let response = try await APIService.shared.updateRentalStatus(id: rental.id, status: newStatus)
                rental.wrappedValue = response.rental
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}

struct ChatNavigator: View {
    let rentalId: String
    @State private var conversation: Conversation?
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if let conversation = conversation {
                ChatDetailView(conversation: conversation)
            } else {
                Text("Could not load chat.")
            }
        }
        .task {
            do {
                let response = try await APIService.shared.getOrCreateConversation(rentalId: rentalId)
                self.conversation = response.conversation
            } catch {
                print(error)
            }
            self.isLoading = false
        }
    }
}
