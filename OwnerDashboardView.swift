//
//  OwnerDashboardView.swift
//  HRENT
//
//  Created by Sayan  Maity  on 01/11/25.
//

import SwiftUI

// --- MODIFICATION ---
// This is a brand new view for the "owner" dashboard
struct OwnerDashboardView: View {
    
    // It also binds to the loggedInUser
    @Binding var loggedInUser: User?
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Owner Dashboard")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if let user = loggedInUser {
                Text("Welcome, Owner \(user.firstName)!")
                    .font(.largeTitle)
                    .foregroundColor(.green) // Make it look different
                
                Text(user.email)
                    .font(.headline)
                
                Text("Role: \(user.userType)")
                    .font(.subheadline)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                
                // You would add your owner-specific controls here
                Text("Manage your properties")
                
            } else {
                Text("Loading owner data...")
            }
            
            Spacer()
            
            Button("Log Out") {
                APIService.shared.authToken = nil
                // Set the user object to nil to log out
                self.loggedInUser = nil
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
}
