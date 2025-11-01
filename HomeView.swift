//
//  HomeView.swift
//  HRENT
//
//  Created by Sayan  Maity  on 31/10/25.
//

import SwiftUI

struct HomeView: View {
    @Binding var isLoggedIn: Bool
    @State private var user: User?
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 20) {
            if let user = user {
                Text("Welcome, \(user.firstName)!")
                    .font(.largeTitle)
                Text(user.email)
                    .font(.headline)
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else {
                ProgressView()
            }
            
            Spacer()
            
            Button("Log Out") {
                APIService.shared.authToken = nil
                self.isLoggedIn = false
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .task {
            await fetchProfile()
        }
    }
    
    func fetchProfile() async {
        do {
            let response = try await APIService.shared.getUserProfile()
            self.user = response.user
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
