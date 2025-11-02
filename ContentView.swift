//
//  ContentView.swift
//  HRENT
//
//  Created by Sayan  Maity  on 31/10/25.
//

import SwiftUI

enum AuthState {
    case welcome
    case login
    case register
}

struct ContentView: View {
    // --- MODIFICATION ---
    // We store the full User object when logged in, not just a Bool.
    // We also check for a saved token on startup.
    @State private var loggedInUser: User? = nil
    @State private var authState: AuthState = .welcome
    @State private var isLoading: Bool = true // For checking token on launch
    
    var body: some View {
        // --- MODIFICATION ---
        // Add a loading view while we check for an existing token
        if isLoading {
            ProgressView()
                .task {
                    await checkInitialAuth()
                }
        }
        // --- MODIFICATION ---
        // If we have a user object, we are logged in.
        else if let user = loggedInUser {
            // --- MODIFICATION ---
            // Now we can route based on the user's role
            if user.userType == .owner {
                OwnerDashboardView(loggedInUser: $loggedInUser)
            } else {
                HomeView(loggedInUser: $loggedInUser)
            }
        } else {
            // --- MODIFICATION ---
            // Pass the $loggedInUser binding to the auth views
            switch authState {
            case .welcome:
                WelcomeView(authState: $authState)
            case .login:
                LoginView(loggedInUser: $loggedInUser, authState: $authState)
            case .register:
                RegisterView(loggedInUser: $loggedInUser, authState: $authState)
            }
        }
    }
    
    // --- MODIFICATION ---
    // Add a function to check for a token on app launch
    func checkInitialAuth() async {
        // In a real app, you would securely load a token from Keychain here
        // For this example, we'll just check the in-memory token
        if let token = APIService.shared.authToken {
            do {
                // We have a token, let's try to get the user profile
                let response = try await APIService.shared.getUserProfile()
                self.loggedInUser = response.user
            } catch {
                // Token is invalid or expired
                APIService.shared.authToken = nil
                self.loggedInUser = nil
            }
        }
        self.isLoading = false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

