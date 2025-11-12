import SwiftUI

struct IncomingRentalsView: View {
    
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
                                await loadIncomingRentals()
                            }
                        }
                    } else if rentals.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "bell.slash.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("No Incoming Requests")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("You have no pending rental requests from users.")
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
                                                .foregroundColor(.black)
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
                                                .foregroundColor(.black)
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
                                                    .foregroundColor(.black)
                                                    .cornerRadius(10)
                                            }
                                            .padding(.horizontal)
                                            .padding(.bottom)
                                        }
                                    }
                                }
                            }
                            .padding()
                            .padding(.bottom, 80)
                        }
                    }
                }
                .background(Color.black)
                .navigationTitle("Incoming Requests")
                .task {
                    await loadIncomingRentals()
                }
                .refreshable {
                     await loadIncomingRentals()
                }
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
