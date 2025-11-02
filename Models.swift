//
//  Models.swift
//  HRENT
//
//  Created by Sayan  Maity  on 31/10/25.
//

import Foundation

// --- MODIFICATION ---
// Add the UserType enum here to make it globally available.
// This will fix the "Cannot find type" error.
enum UserType: String, CaseIterable, Identifiable, Codable {
    case user = "user"
    case owner = "owner"
    var id: Self { self }
    
    var displayName: String {
        switch self {
        case .user:
            return "Normal User"
        case .owner:
            return "House Owner"
        }
    }
}

struct User: Codable, Identifiable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let isVerified: Bool
    
    // --- MODIFICATION ---
    // Use the UserType enum directly
    let userType: UserType

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case firstName, lastName, email, isVerified
        // --- MODIFICATION ---
        // Add userType to the coding keys
        case userType
    }
}

struct AuthResponse: Codable {
    let success: Bool
    let token: String
    let user: User
}

struct UserProfileResponse: Codable {
    let success: Bool
    let user: User
}

struct MessageResponse: Codable {
    let success: Bool
    let message: String
}

struct RegistrationOTPRequest: Encodable {
    let firstName: String
    let lastName: String
    let email: String
    
    // --- MODIFICATION ---
    // Use the UserType enum for better type safety
    let userType: UserType
}

struct VerifyOTPRequest: Encodable {
    let email: String
    let otp: String
}

struct LoginOTPRequest: Encodable {
    let email: String
}

struct GoogleAuthRequest: Encodable {
    let email: String
    let firstName: String
    let lastName: String
    let googleId: String
    
    // --- MODIFICATION ---
    // Use the UserType enum here as well
    let userType: UserType
}

struct UpdateProfileRequest: Encodable {
    let firstName: String?
    let lastName: String?
}
