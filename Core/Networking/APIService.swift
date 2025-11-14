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
            self.updateUserId()
        }
    }
    
    private(set) var userId: String?
    
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init() {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        decoder = JSONDecoder()
        
        encoder = JSONEncoder()
        
        self.updateUserId()
    }
    
    private func updateUserId() {
        guard let token = authToken else {
            self.userId = nil
            return
        }
        
        let segments = token.split(separator: ".").map { String($0) }
        
        guard segments.count > 1 else {
            self.userId = nil
            return
        }
        
        self.userId = decodeJWT(token: token)["id"] as? String
    }
    
    private func decodeJWT(token jwt: String) -> [String: Any] {
      let segments = jwt.split(separator: ".")
      guard segments.count > 1 else {
        return [:]
      }
      
      var base64String = String(segments[1])
      
      base64String = base64String.replacingOccurrences(of: "-", with: "+")
      base64String = base64String.replacingOccurrences(of: "_", with: "/")
      
      let requiredLength = 4 * ceil(Double(base64String.count) / 4.0)
      let paddingLength = Int(requiredLength) - base64String.count
      if paddingLength > 0 {
          let padding = String(repeating: "=", count: paddingLength)
          base64String += padding
      }
      
      guard let data = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters) else {
        return [:]
      }
      
      return (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any] ?? [:]
    }

    
    
    
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
    
    
    
    func getAllProperties(sortBy: String) async throws -> PropertiesResponse {
        var components = URLComponents(url: baseURL.appendingPathComponent("/properties"), resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "sortBy", value: sortBy)
        ]
        
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        
        return try await performRequest(
            url: url,
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
    
    func updatePropertyStatus(id: String, status: PropertyStatus) async throws -> PropertyResponse {
        let body = UpdatePropertyRequest(
            title: nil,
            description: nil,
            address: nil,
            images: nil,
            price: nil,
            pricingFrequency: nil,
            allowBargaining: nil,
            status: status
        )
        return try await performRequest(
            endpoint: "/properties/\(id)",
            method: "PUT",
            body: body,
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
    
    
    
    func getMyConversations() async throws -> ConversationsResponse {
        return try await performRequest(
            endpoint: "/chat",
            method: "GET",
            requiresAuth: true
        )
    }
    
    func getOrCreateConversation(rentalId: String) async throws -> ConversationResponse {
        let body = InitiateChatRequest(rentalId: rentalId)
        return try await performRequest(
            endpoint: "/chat/initiate",
            method: "POST",
            body: body,
            requiresAuth: true
        )
    }
    
    func getMessages(conversationId: String) async throws -> MessagesResponse {
        return try await performRequest(
            endpoint: "/chat/\(conversationId)/messages",
            method: "GET",
            requiresAuth: true
        )
    }
    
    func sendMessage(conversationId: String, text: String?, imageUrl: String?) async throws -> MessageServiceResponse {
        let body = SendMessageRequest(text: text, imageUrl: imageUrl)
        return try await performRequest(
            endpoint: "/chat/\(conversationId)/messages",
            method: "POST",
            body: body,
            requiresAuth: true
        )
    }
    
    func editMessage(messageId: String, text: String) async throws -> MessageServiceResponse {
        let body = EditMessageRequest(text: text)
        return try await performRequest(
            endpoint: "/chat/messages/\(messageId)",
            method: "PUT",
            body: body,
            requiresAuth: true
        )
    }
    
    func reactToMessage(messageId: String, emoji: String) async throws -> MessageServiceResponse {
        let body = ReactToMessageRequest(emoji: emoji)
        return try await performRequest(
            endpoint: "/chat/messages/\(messageId)/react",
            method: "POST",
            body: body,
            requiresAuth: true
        )
    }
    
    
    
    func uploadImage(imageData: Data) async throws -> UploadResponse {
        let url = baseURL.appendingPathComponent("/upload")
        
        guard let token = authToken else {
            throw APIError.requestFailed(statusCode: 401, message: "Not authorized. No token available.")
        }
        
        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"upload.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        return try await sendAndDecode(request: request)
    }

    
    
    
    private func performRequest<T: Decodable, U: Encodable>(
        endpoint: String,
        method: String,
        body: U,
        requiresAuth: Bool = false
    ) async throws -> T {
        
        let url = baseURL.appendingPathComponent(endpoint)
        return try await performRequest(url: url, method: method, body: body, requiresAuth: requiresAuth)
    }
    
    private func performRequest<T: Decodable, U: Encodable>(
        url: URL,
        method: String,
        body: U,
        requiresAuth: Bool = false
    ) async throws -> T {
        
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
        return try await performRequest(url: url, method: method, requiresAuth: requiresAuth)
    }
    
    private func performRequest<T: Decodable>(
        url: URL,
        method: String,
        requiresAuth: Bool = false
    ) async throws -> T {
        
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
