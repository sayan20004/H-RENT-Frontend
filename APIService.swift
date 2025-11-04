import Foundation

class APIService {
    
    static let shared = APIService()
    
    private let baseURL = URL(string: "https://hrentapi.onrender.com/api")!
    
    private let tokenKey = "authToken"
    
    var authToken: String? {
        get {
            UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            if let token = newValue {
                UserDefaults.standard.setValue(token, forKey: tokenKey)
            } else {
                UserDefaults.standard.removeObject(forKey: tokenKey)
            }
        }
    }
    
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init() {
        decoder = JSONDecoder()
        encoder = JSONEncoder()
    }
    
    // MARK: - Auth
    
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
        self.authToken = response.token
        return response
    }
    
    func registerOrLoginWithGoogle(email: String, firstName: String, lastName: String, googleId: String, userType: UserType = .user) async throws -> AuthResponse {
        let body = GoogleAuthRequest(email: email, firstName: firstName, lastName: lastName, googleId: googleId, userType: userType)
        let response: AuthResponse = try await performRequest(
            endpoint: "/auth/google-auth",
            method: "POST",
            body: body
        )
        self.authToken = response.token
        return response
    }
    
    // MARK: - User
    
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
    
    // MARK: - Properties
    
    func getAllProperties() async throws -> PropertiesResponse {
        return try await performRequest(
            endpoint: "/properties",
            method: "GET",
            requiresAuth: true
        )
    }
    
    func getMyProperties() async throws -> PropertiesResponse {
        return try await performRequest(
            endpoint: "/properties/my-properties",
            method: "GET",
            requiresAuth: true
        )
    }
    
    func createProperty(
        title: String,
        description: String,
        address: String,
        images: [String],
        price: Double,
        pricingFrequency: PricingFrequency,
        allowBargaining: Bool
    ) async throws -> PropertyResponse {
        let body = CreatePropertyRequest(
            title: title,
            description: description,
            address: address,
            images: images,
            price: price,
            pricingFrequency: pricingFrequency,
            allowBargaining: allowBargaining
        )
        return try await performRequest(
            endpoint: "/properties",
            method: "POST",
            body: body,
            requiresAuth: true
        )
    }
    
    func updateProperty(id: String, requestBody: UpdatePropertyRequest) async throws -> PropertyResponse {
        return try await performRequest(
            endpoint: "/properties/\(id)",
            method: "PUT",
            body: requestBody,
            requiresAuth: true
        )
    }
    
    func deleteProperty(id: String) async throws -> MessageResponse {
        return try await performRequest(
            endpoint: "/properties/\(id)",
            method: "DELETE",
            requiresAuth: true
        )
    }
    
    // MARK: - Rentals
    
    func createRentalRequest(propertyId: String) async throws -> RentalResponse {
        let body = CreateRentalRequest(propertyId: propertyId)
        return try await performRequest(
            endpoint: "/rentals",
            method: "POST",
            body: body,
            requiresAuth: true
        )
    }
    
    func getMyRentalRequests() async throws -> RentalsResponse {
        return try await performRequest(
            endpoint: "/rentals/my-requests",
            method: "GET",
            requiresAuth: true
        )
    }
    
    func getIncomingRentalRequests() async throws -> RentalsResponse {
        return try await performRequest(
            endpoint: "/rentals/incoming-requests",
            method: "GET",
            requiresAuth: true
        )
    }
    
    func updateRentalStatus(id: String, status: RentalStatus) async throws -> RentalResponse {
        let body = UpdateRentalStatusRequest(status: status)
        return try await performRequest(
            endpoint: "/rentals/\(id)/status",
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
        
        if data.isEmpty {
            if T.self == MessageResponse.self {
                 return MessageResponse(success: true, message: "Operation successful") as! T
            } else {
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
