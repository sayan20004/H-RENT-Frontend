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
    @State private var isLoggedIn: Bool = false
    @State private var authState: AuthState = .welcome

    var body: some View {
        if isLoggedIn {
            HomeView(isLoggedIn: $isLoggedIn)
        } else {
            switch authState {
            case .welcome:
                WelcomeView(authState: $authState)
            case .login:
                LoginView(isLoggedIn: $isLoggedIn, authState: $authState)
            case .register:
                RegisterView(isLoggedIn: $isLoggedIn, authState: $authState)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

