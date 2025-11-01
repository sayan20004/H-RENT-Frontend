//
//  RegisterView.swift
//  HRENT
//
//  Created by Sayan  Maity  on 31/10/25.
//
import SwiftUI

// --- MODIFICATION ---
// A simple enum to manage the user role selection
enum UserType: String, CaseIterable, Identifiable {
    case user = "user"
    case owner = "owner"
    var id: Self { self }
    
    var displayName: String {
        switch self {
        case .user:
            return "Normal User"
        case .owner:
            return "House Owner"
        }
    }
}

struct RegisterView: View {
    // --- MODIFICATION ---
    // We now bind to the loggedInUser object instead of just a Bool
    @Binding var loggedInUser: User?
    @Binding var authState: AuthState
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var otp: String = ""
    
    // --- MODIFICATION ---
    // Add state for the new userType picker
    @State private var userType: UserType = .user
    
    @State private var errorMessage: String?
    @State private var isOTPSent: Bool = false
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Button {
                    authState = .welcome
                } label: {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                Spacer()
            }
            .padding(.bottom, 20)
            
            Text("Sign Up")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            if isOTPSent {
                TextField("OTP", text: $otp)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                
                Button("Verify & Sign Up") {
                    verifyRegistration()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
            } else {
                TextField("First Name", text: $firstName)
                    .textFieldStyle(.roundedBorder)
                TextField("Last Name", text: $lastName)
                    .textFieldStyle(.roundedBorder)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textFieldStyle(.roundedBorder)
                
                // --- MODIFICATION ---
                // Add a Picker to select the user role
                Picker("I am a...", selection: $userType) {
                    ForEach(UserType.allCases) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                // --- END MODIFICATION ---

                Button("Send Registration OTP") {
                    sendOTP()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Spacer()
            
            Button {
                authState = .login
            } label: {
                Text("Already have an account? ")
                + Text("Log In").fontWeight(.bold)
            }
            .padding(.top)
        }
        .padding()
    }
    
    func sendOTP() {
        Task {
            do {
                // --- MODIFICATION ---
                // Pass the userType to the API service
                _ = try await APIService.shared.sendRegistrationOTP(
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    userType: userType.rawValue // Pass the selected role
                )
                self.isOTPSent = true
                self.errorMessage = nil
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func verifyRegistration() {
        Task {
            do {
                let response = try await APIService.shared.verifyRegistrationOTP(
                    email: email,
                    otp: otp
                )
                APIService.shared.authToken = response.token
                self.errorMessage = nil
                // --- MODIFICATION ---
                // Set the full user object on success
                self.loggedInUser = response.user
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
