//
//  WelcomeView.swift
//  HRENT
//
//  Created by Sayan  Maity  on 31/10/25.
//

import SwiftUI

struct WelcomeView: View {
    @Binding var authState: AuthState

    var body: some View {
        // --- MODIFICATION ---
        // We define our custom colors from the design
        let appGreen = Color(red: 167/255, green: 212/255, blue: 95/255)
        let appGray = Color(red: 243/255, green: 243/255, blue: 243/255)

        VStack(spacing: 0) {
            
            // --- MODIFICATION ---
            // This ZStack creates the overlapping image collage.
            // You must add "welcome-image-1" and "welcome-image-2"
            // to your Assets.xcassets.
            ZStack {
                // Background Image
                Image("welcome-image-1")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 220, height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .rotationEffect(.degrees(-10))
                    .offset(x: -30, y: 10)
                    .shadow(color: .black.opacity(0.15), radius: 10, y: 5)

                // Foreground Image
                Image("welcome-image-2")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 220, height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .rotationEffect(.degrees(10))
                    .offset(x: 40, y: 70)
                    .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
            }
            .padding(.top, 60) // Add padding from the status bar
            .padding(.bottom, 40) // Space before the indicator

            // --- MODIFICATION ---
            // The small green page indicator
            Capsule()
                .fill(appGreen)
                .frame(width: 50, height: 5)
                .padding(.bottom, 30)

            // --- MODIFICATION ---
            // The main text content
            VStack(spacing: 12) {
                Text("Welcome Back!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Sign In or Register")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.primary.opacity(0.9))
                
                Text("Create an account in minutes to access exclusive features, track your activity, and stay updated.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            // Spacer to push the buttons to the bottom
            Spacer()
            
            // --- MODIFICATION ---
            // The new styled buttons
            VStack(spacing: 15) {
                // Registration Button
                Button {
                    authState = .register
                } label: {
                    Text("Registration")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(appGreen)
                        .foregroundColor(.black)
                        .cornerRadius(14)
                }
                
                // Sign In Button
                Button {
                    authState = .login
                } label: {
                    Text("Sign In")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(appGray)
                        .foregroundColor(.black)
                        .cornerRadius(14)
                }
            }
        }
        .padding(.horizontal, 24) // Add horizontal padding to the whole view
        .padding(.bottom) // Add padding for the home bar
        .edgesIgnoringSafeArea(.top) // Allow images to go to the top
    }
}
