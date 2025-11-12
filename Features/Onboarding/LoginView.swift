import SwiftUI

struct LoginView: View {
    @Binding var loggedInUser: User?
    @Binding var authState: AuthState
    
    @State private var email: String = ""
    @State private var otp: String = ""
    @State private var errorMessage: String?
    @State private var isOTPSent: Bool = false
    
    // Theme Colors
    private let backgroundColor = Color(red: 44/255, green: 30/255, blue: 24/255)
    private let buttonColor = Color(red: 219/255, green: 173/255, blue: 147/255)
    private let textFieldColor = Color(red: 64/255, green: 43/255, blue: 34/255)
    private let errorColor = Color(red: 239/255, green: 68/255, blue: 68/255)
    private let lightTextColor = Color.white.opacity(0.9)
    private let placeholderColor = Color.white.opacity(0.6)

    var body: some View {
        ZStack {
            backgroundColor
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    Image(systemName: "app.dashed")
                        .font(.system(size: 40))
                        .foregroundColor(lightTextColor)
                        .padding(.top, 40)
                        .padding(.bottom, 20)

                    Text(isOTPSent ? "Enter OTP" : "Log In")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(lightTextColor)
                    
                    if isOTPSent {
                        Text("Enter the 6-digit OTP code that we sent to")
                            .font(.subheadline)
                            .foregroundColor(lightTextColor.opacity(0.8))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(email)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 10)
                            .foregroundColor(lightTextColor)

                        OTPInputView(otp: $otp)
                        
                        TimerView(onResend: sendOTP)
                            .padding(.top, 10)
                            .colorScheme(.dark)

                        AuthButton(title: "Confirm", icon: "arrow.right") {
                            verifyLogin()
                        }
                        
                    } else {
                        
                        Text("Email Address")
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(lightTextColor)
                        
                        CustomTextField(
                            text: $email,
                            prompt: "Enter your email...",
                            iconName: "envelope",
                            isError: errorMessage != nil && !email.isEmpty
                        )
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)

                        AuthButton(title: "Send Login OTP", icon: "arrow.right") {
                            sendOTP()
                        }
                    }
                    
                    if let errorMessage = errorMessage {
                        ErrorView(message: errorMessage)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            
            VStack {
                Spacer()
                Button {
                    authState = .register
                } label: {
                    Text("Don't have an account? ")
                        .foregroundColor(lightTextColor.opacity(0.7))
                    + Text("Sign Up").underline()
                        .foregroundColor(buttonColor)
                }
                .padding(.bottom, 20)
            }
        }
    }
    
    func sendOTP() {
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

// MARK: - Reusable Themed Components

private let backgroundColor = Color(red: 44/255, green: 30/255, blue: 24/255)
private let buttonColor = Color(red: 219/255, green: 173/255, blue: 147/255)
private let textFieldColor = Color(red: 64/255, green: 43/255, blue: 34/255)
private let errorColor = Color(red: 239/255, green: 68/255, blue: 68/255)
private let lightTextColor = Color.white.opacity(0.9)
private let placeholderColor = Color.white.opacity(0.6)

struct CustomTextField: View {
    @Binding var text: String
    var prompt: String
    var iconName: String
    var isError: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .foregroundColor(placeholderColor)
            
            TextField("", text: $text, prompt: Text(prompt).foregroundColor(placeholderColor))
                .foregroundColor(lightTextColor)
        }
        .padding()
        .background(textFieldColor)
        .cornerRadius(100) // Fully rounded corners
        .overlay(
            RoundedRectangle(cornerRadius: 100)
                .stroke(isError ? errorColor : Color.clear, lineWidth: 1.5)
        )
    }
}

struct AuthButton: View {
    var title: String
    var icon: String? = nil
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                Text(title)
                    .fontWeight(.bold)
                if let icon = icon {
                    Image(systemName: icon)
                }
                Spacer()
            }
            .padding()
            .background(buttonColor)
            .foregroundColor(backgroundColor)
            .cornerRadius(100)
        }
    }
}

struct ErrorView: View {
    var message: String
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
            Text(message)
                .fontWeight(.medium)
            Spacer()
        }
        .padding(12)
        .foregroundColor(errorColor)
        .background(errorColor.opacity(0.1))
        .cornerRadius(8)
    }
}
