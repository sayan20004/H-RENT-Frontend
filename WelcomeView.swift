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
        VStack(spacing: 20) {
            Spacer()
            
            Text("Welcome to H-Rent")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Find your next rental home.")
                .font(.title3)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button {
                authState = .login
            } label: {
                Text("Log In")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Button {
                authState = .register
            } label: {
                Text("Sign Up")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}
