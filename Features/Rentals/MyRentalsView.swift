import SwiftUI

struct MyRentalsView: View {
    @State private var rentals: [Rental] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    private let appGreen = Color(red: 104/255, green: 222/255, blue: 122/255)

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            NavigationView {
                VStack {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let errorMessage = errorMessage {
                        ErrorStateView(message: errorMessage) {
                            Task {
                                await loadMyRentals()
                            }
                        }
                    } else if rentals.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "key.slash.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("No Rental Requests")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Your requested and active rentals will appear here.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            VStack(spacing: 16) {
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
                                                        .foregroundColor(.black)
                                                        .cornerRadius(10)
                                                }
                                            }
                                        }
                                        .padding(.horizontal)
                                        .padding(.bottom)
                                    }
                                }
                            }
                            .padding()
                            .padding(.bottom, 80)
                        }
                    }
                }
                .background(Color.black)
                .navigationTitle("My Rentals")
                .task {
                    await loadMyRentals()
                }
                .refreshable {
                     await loadMyRentals()
                }
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
