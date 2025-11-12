import SwiftUI

struct RegisterView: View {
    @Binding var loggedInUser: User?
    @Binding var authState: AuthState
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var otp: String = ""
    
    @State private var userType: UserType = .user
    
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

                    Text(isOTPSent ? "Enter OTP" : "Sign Up For Free")
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

                        AuthButton(title: "Confirm & Sign Up", icon: "arrow.right") {
                            verifyRegistration()
                        }
                        
                    } else {
                        
                        CustomTextField(
                            text: $firstName,
                            prompt: "Enter your first name...",
                            iconName: "person",
                            isError: errorMessage != nil && firstName.isEmpty
                        )
                        
                        CustomTextField(
                            text: $lastName,
                            prompt: "Enter your last name...",
                            iconName: "person",
                            isError: errorMessage != nil && lastName.isEmpty
                        )
                        
                        Text("Email Address")
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(lightTextColor)
                        
                        CustomTextField(
                            text: $email,
                            prompt: "Enter your email...",
                            iconName: "envelope",
                            isError: errorMessage != nil && !email.contains("@")
                        )
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        
                        Picker("I am a...", selection: $userType) {
                            ForEach(UserType.allCases) { type in
                                Text(type.displayName).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(4)
                        .background(textFieldColor)
                        .cornerRadius(8)

                        AuthButton(title: "Send Registration OTP", icon: "arrow.right") {
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
                    authState = .login
                } label: {
                    Text("Already have an account? ")
                        .foregroundColor(lightTextColor.opacity(0.7))
                    + Text("Sign In").underline()
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
