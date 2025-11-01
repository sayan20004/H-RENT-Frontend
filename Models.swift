//
//  Models.swift
//  HRENT
//
//  Created by Sayan  Maity  on 31/10/25.
//

//
//  Models.swift
//  HRENT
//
//  Created by Sayan  Maity  on 31/10/25.
//

import Foundation

struct User: Codable, Identifiable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let isVerified: Bool
    // --- MODIFICATION ---
    // Add the new userType field to match your backend model
    let userType: String

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
    // Add userType to send during registration
    let userType: String
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
    // Add userType to send during Google auth
    let userType: String
}

struct UpdateProfileRequest: Encodable {
    let firstName: String?
    let lastName: String?
}
