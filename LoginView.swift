import SwiftUI

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @Binding var authState: AuthState
    
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
            
            Text("Log In")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)
            
            if isOTPSent {
                TextField("OTP", text: $otp)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                
                Button("Verify and Log In") {
                    verifyLogin()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
            } else {
                Button("Send Login OTP") {
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
                self.isLoggedIn = true
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
