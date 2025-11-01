//
//  RegisterView.swift
//  HRENT
//
//  Created by Sayan  Maity  on 31/10/25.
//
import SwiftUI

struct RegisterView: View {
    @Binding var isLoggedIn: Bool
    @Binding var authState: AuthState
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var otp: String = ""
    
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
                _ = try await APIService.shared.sendRegistrationOTP(
                    firstName: firstName,
                    lastName: lastName,
                    email: email
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
                self.isLoggedIn = true
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
