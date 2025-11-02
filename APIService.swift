//
//  APIService.swift
//  HRENT
//
//  Created by Sayan  Maity  on 31/10/25.
//

import Foundation

class APIService {
    
    static let shared = APIService()
    
    // --- MODIFICATION ---
    // Swapped to your local server URL for testing
    // private let baseURL = URL(string: "http://localhost:5001/api")!
    // Make sure to use your deployed URL for production
    private let baseURL = URL(string: "https://hrentapi.onrender.com/api")!
    
    var authToken: String?
    
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    // --- MODIFICATION ---
    // Initialize decoder in the init
    init() {
        decoder = JSONDecoder()
        encoder = JSONEncoder()
    }
    
    // --- MODIFICATION ---
    // Changed the parameter from String to the UserType enum
    func sendRegistrationOTP(firstName: String, lastName: String, email: String, userType: UserType) async throws -> MessageResponse {
        let body = RegistrationOTPRequest(firstName: firstName, lastName: lastName, email: email, userType: userType)
        return try await performRequest(
            endpoint: "/auth/register-send-otp",
            method: "POST",
            body: body
        )
    }
    
    func verifyRegistrationOTP(email: String, otp: String) async throws -> AuthResponse {
        let body = VerifyOTPRequest(email: email, otp: otp)
        let response: AuthResponse = try await performRequest(
            endpoint: "/auth/register-verify-otp",
            method: "POST",
            body: body
        )
        // --- MODIFICATION ---
        // Save the token on successful verification
        self.authToken = response.token
        return response
    }
    
    func sendLoginOTP(email: String) async throws -> MessageResponse {
        let body = LoginOTPRequest(email: email)
        return try await performRequest(
            endpoint: "/auth/login-send-otp",
            method: "POST",
            body: body
        )
    }
    
    func verifyLoginOTP(email: String, otp: String) async throws -> AuthResponse {
        let body = VerifyOTPRequest(email: email, otp: otp)
        let response: AuthResponse = try await performRequest(
            endpoint: "/auth/login-verify-otp",
            method: "POST",
            body: body
        )
        // --- MODIFICATION ---
        // Save the token on successful login
        self.authToken = response.token
        return response
    }
    
    // --- MODIFICATION ---
    // Changed the parameter from String to the UserType enum
    // Also added a default "user" type for Google Sign in
    func registerOrLoginWithGoogle(email: String, firstName: String, lastName: String, googleId: String, userType: UserType = .user) async throws -> AuthResponse {
        let body = GoogleAuthRequest(email: email, firstName: firstName, lastName: lastName, googleId: googleId, userType: userType)
        let response: AuthResponse = try await performRequest(
            endpoint: "/auth/google-auth",
            method: "POST",
            body: body
        )
        // --- MODIFICATION ---
        // Save the token on successful Google auth
        self.authToken = response.token
        return response
    }
    
    func getUserProfile() async throws -> UserProfileResponse {
        return try await performRequest(
            endpoint: "/user/profile",
            method: "GET",
            requiresAuth: true
        )
    }
    
    func updateUserProfile(firstName: String?, lastName: String?) async throws -> UserProfileResponse {
        let body = UpdateProfileRequest(firstName: firstName, lastName: lastName)
        return try await performRequest(
            endpoint: "/user/profile",
            method: "PUT",
            body: body,
            requiresAuth: true
        )
    }
    
    // --- Private Helper Functions ---
    
    private func performRequest<T: Decodable, U: Encodable>(
        endpoint: String,
        method: String,
        body: U,
        requiresAuth: Bool = false
    ) async throws -> T {
        
        let url = baseURL.appendingPathComponent(endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if requiresAuth {
            guard let token = authToken else {
                throw APIError.requestFailed(statusCode: 401, message: "Not authorized. No token available.")
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpBody = try encoder.encode(body)
        
        return try await sendAndDecode(request: request)
    }
    
    private func performRequest<T: Decodable>(
        endpoint: String,
        method: String,
        requiresAuth: Bool = false
    ) async throws -> T {
        
        let url = baseURL.appendingPathComponent(endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if requiresAuth {
            guard let token = authToken else {
                throw APIError.requestFailed(statusCode: 401, message: "Not authorized. No token available.")
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return try await sendAndDecode(request: request)
    }
    
    private func sendAndDecode<T: Decodable>(request: URLRequest) async throws -> T {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown(URLError(.badServerResponse))
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            if data.isEmpty {
                throw APIError.requestFailed(statusCode: httpResponse.statusCode, message: "Request failed with status code \(httpResponse.statusCode).")
            }
            
            if let apiError = try? decoder.decode(APIErrorResponse.self, from: data) {
                throw APIError.requestFailed(statusCode: httpResponse.statusCode, message: apiError.message)
            }
            throw APIError.requestFailed(statusCode: httpResponse.statusCode, message: "An unknown error occurred.")
        }
        
        // Handle empty success response
        if data.isEmpty {
            if T.self == MessageResponse.self {
                 return MessageResponse(success: true, message: "Operation successful") as! T
            } else {
                // If we expect data but get none, it's a decoding error
                throw APIError.decodingError(URLError(.cannotParseResponse))
            }
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print("--- DECODING ERROR ---")
            print(error)
            if let jsonString = String(data: data, encoding: .utf8) {
                print("--- FAILED JSON ---")
                print(jsonString)
            }
            print("----------------------")
            throw APIError.decodingError(error)
        }
    }
}
