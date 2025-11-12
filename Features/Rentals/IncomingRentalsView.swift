import SwiftUI

struct IncomingRentalsView: View {
    
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
                        Text("You have no incoming rental requests.")
                            .foregroundColor(.secondary)
                            .padding(.top, 50)
                    } else {
                        ForEach($rentals) { $rental in
                            VStack(spacing: 0) {
                                RentalCardView(rental: rental)
                                
                                if rental.status == .pending {
                                    HStack(spacing: 10) {
                                        Button("Deny") {
                                            updateStatus(for: $rental, to: .denied)
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.red)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        
                                        Button("Accept") {
                                            updateStatus(for: $rental, to: .accepted)
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(appGreen)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                    }
                                    .padding(.horizontal)
                                    .padding(.bottom)
                                } else if rental.status == .cancellationRequested {
                                    HStack(spacing: 10) {
                                        Button("Deny Cancellation") {
                                            updateStatus(for: $rental, to: .accepted)
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.red)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        
                                        Button("Approve Cancellation") {
                                            updateStatus(for: $rental, to: .cancelled)
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(appGreen)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                    }
                                    .padding(.horizontal)
                                    .padding(.bottom)
                                } else if rental.status == .accepted {
                                    NavigationLink(destination: ChatNavigator(rentalId: rental.id)) {
                                        Text("Contact Tenant")
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(appGreen)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                    }
                                    .padding(.horizontal)
                                    .padding(.bottom)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Incoming Requests")
            .task {
                await loadIncomingRentals()
            }
            .refreshable {
                 await loadIncomingRentals()
            }
        }
    }
    
    func loadIncomingRentals() async {
        isLoading = true
        errorMessage = nil
        do {
            let response = try await APIService.shared.getIncomingRentalRequests()
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
