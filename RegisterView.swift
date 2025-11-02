//
//  RegisterView.swift
//  HRENT
//
//  Created by Sayan  Maity  on 31/10/25.
//
import SwiftUI

// --- MODIFICATION ---
// The UserType enum definition is REMOVED from this file.
// It is now in Models.swift.

struct RegisterView: View {
    @Binding var loggedInUser: User?
    @Binding var authState: AuthState
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var otp: String = ""
    
    // This will now correctly find the global UserType from Models.swift
    @State private var userType: UserType = .user
    
    @State private var errorMessage: String?
    @State private var isOTPSent: Bool = false
    
    private let appGreen = Color(red: 62/255, green: 178/255, blue: 82/255)
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Button {
                    if isOTPSent {
                        isOTPSent = false
                        errorMessage = nil
                        otp = ""
                    } else {
                        authState = .welcome
                    }
                } label: {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                Spacer()
            }
            .padding(.bottom, 20)
            
            Text(isOTPSent ? "Enter OTP" : "Sign Up")
                .font(.largeTitle)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if isOTPSent {
                Text("Enter the 6-digit OTP code that we sent to")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(email)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)
                
                OTPInputView(otp: $otp)
                
                TimerView(onResend: sendOTP)
                    .padding(.top, 10)

                Button("Confirm & Sign Up") {
                    verifyRegistration()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(appGreen)
                .foregroundColor(.white)
                .cornerRadius(14)
                .padding(.top, 20)
                
            } else {
                TextField("First Name", text: $firstName)
                    .textFieldStyle(.roundedBorder)
                TextField("Last Name", text: $lastName)
                    .textFieldStyle(.roundedBorder)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textFieldStyle(.roundedBorder)
                
                // This Picker will now work and won't cause the "Generic parameter" error
                Picker("I am a...", selection: $userType) {
                    ForEach(UserType.allCases) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .pickerStyle(.segmented)

                Button("Send Registration OTP") {
                    sendOTP()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(appGreen)
                .foregroundColor(.white)
                .cornerRadius(14)
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
        otp = ""
        errorMessage = nil
        Task {
            do {
                // --- MODIFICATION ---
                // We now pass the 'userType' enum case directly.
                // JSONEncoder will handle converting it to a string ("user" or "owner").
                _ = try await APIService.shared.sendRegistrationOTP(
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    userType: userType
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
                self.loggedInUser = response.user
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
