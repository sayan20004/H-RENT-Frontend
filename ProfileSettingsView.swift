//
//  ProfileSettingsView.swift
//  HRENT
//
//  Created by Sayan  Maity  on 04/11/25.
//

import SwiftUI

struct ProfileSettingsView: View {
    @Binding var loggedInUser: User?
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var errorMessage: String?
    @State private var successMessage: String?
    
    private let appGreen = Color(red: 62/255, green: 178/255, blue: 82/255)
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("First Name", text: $firstName)
                        .textContentType(.givenName)
                    TextField("Last Name", text: $lastName)
                        .textContentType(.familyName)
                }
                
                Section(header: Text("Account Details")) {
                    Text(loggedInUser?.email ?? "No email")
                        .foregroundColor(.secondary)
                    Text("Role: \(loggedInUser?.userType.displayName ?? "Unknown")")
                        .foregroundColor(.secondary)
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                if let successMessage = successMessage {
                    Section {
                        Text(successMessage)
                            .foregroundColor(appGreen)
                    }
                }
                
                Button("Save Changes") {
                    updateProfile()
                }
                .tint(appGreen)
                
                Section {
                    Button("Log Out") {
                        logout()
                    }
                    .tint(.red)
                }
            }
            .navigationTitle("Profile Settings")
            .onAppear {
                if let user = loggedInUser {
                    self.firstName = user.firstName
                    self.lastName = user.lastName
                }
            }
        }
    }
    
    func updateProfile() {
        Task {
            do {
                let response = try await APIService.shared.updateUserProfile(
                    firstName: self.firstName,
                    lastName: self.lastName
                )
                self.loggedInUser = response.user
                self.successMessage = "Profile updated successfully!"
                self.errorMessage = nil
            } catch {
                self.errorMessage = error.localizedDescription
                self.successMessage = nil
            }
        }
    }
    
    func logout() {
        APIService.shared.authToken = nil
        self.loggedInUser = nil
    }
}
