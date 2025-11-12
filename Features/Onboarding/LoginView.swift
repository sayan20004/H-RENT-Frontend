import SwiftUI

struct LoginView: View {
    @Binding var loggedInUser: User?
    @Binding var authState: AuthState
    
    @State private var email: String = ""
    @State private var otp: String = ""
    @State private var errorMessage: String?
    @State private var isOTPSent: Bool = false
    
    // --- MODIFICATION ---
    // Define the brand green color
    private let appGreen = Color(red: 62/255, green: 178/255, blue: 82/255)
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Button {
                    // --- MODIFICATION ---
                    // If OTP is sent, back button goes to email step
                    // Otherwise, it goes to Welcome
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
            
            // --- MODIFICATION ---
            // Show email or OTP title
            Text(isOTPSent ? "Enter OTP" : "Log In")
                .font(.largeTitle)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if isOTPSent {
                // --- MODIFICATION ---
                // Subtitle for OTP screen
                Text("Enter the 6-digit OTP code that we sent to")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(email)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)

                // --- MODIFICATION ---
                // Use the new OTPInputView
                OTPInputView(otp: $otp)
                
                // --- MODIFICATION ---
                // Use the new TimerView
                TimerView(onResend: sendOTP)
                    .padding(.top, 10)

                Button("Confirm") { // Changed text
                    verifyLogin()
                }
                .padding()
                .frame(maxWidth: .infinity)
                // --- MODIFICATION ---
                // Styled like the screenshot
                .background(appGreen)
                .foregroundColor(.white)
                .cornerRadius(14)
                .padding(.top, 20)
                
            } else {
                // This is the original email entry screen
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textFieldStyle(.roundedBorder)
                
                Button("Send Login OTP") {
                    sendOTP()
                }
                .padding()
                .frame(maxWidth: .infinity)
                // --- MODIFICATION ---
                // Use the brand green here too
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
                authState = .register
            } label: {
                Text("Don't have an account? ")
                + Text("Sign Up").fontWeight(.bold)
            }
            .padding(.top)
        }
        .padding()
    }
    
    func sendOTP() {
        // --- MODIFICATION ---
        // Clear old OTP and error when resending
        otp = ""
        errorMessage = nil
        Task {
            do {
                _ = try await APIService.shared.sendLoginOTP(email: email)
                self.isOTPSent = true
                self.errorMessage = nil
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func verifyLogin() {
        Task {
            do {
                let response = try await APIService.shared.verifyLoginOTP(email: email, otp: otp)
                APIService.shared.authToken = response.token
                self.errorMessage = nil
                self.loggedInUser = response.user
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
