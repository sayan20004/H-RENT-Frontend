import Foundation
import SwiftUI

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
    let userType: UserType

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case firstName, lastName, email, isVerified
        case userType
    }
}

enum PricingFrequency: String, CaseIterable, Identifiable, Codable {
    case monthly
    case weekly
    case quarterly
    case yearly
    var id: Self { self }
    
    var displayName: String {
        return self.rawValue.capitalized
    }
}

enum PropertyStatus: String, CaseIterable, Identifiable, Codable {
    case active
    case hidden
    case deleted
    var id: Self { self }
    
    var displayName: String {
        return self.rawValue.capitalized
    }
}

struct PropertyOwner: Codable {
    let firstName: String?
    let lastName: String?
    let email: String?
}

struct Property: Codable, Identifiable, Hashable {
    static func == (lhs: Property, rhs: Property) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id: String
    let owner: PropertyOwner
    let title: String
    let description: String
    let address: String
    let images: [String]
    let price: Double
    let pricingFrequency: PricingFrequency
    let allowBargaining: Bool
    let status: PropertyStatus

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case owner, title, description, address, images, price, pricingFrequency, allowBargaining, status
    }
}

enum RentalStatus: String, Codable {
    case pending
    case accepted
    case denied
    case cancelled
    case cancellationRequested
    
    var displayName: String {
        switch self {
        case .pending:
            return "Pending"
        case .accepted:
            return "Accepted"
        case .denied:
            return "Denied"
        case .cancelled:
            return "Cancelled"
        case .cancellationRequested:
            return "Cancellation Requested"
        }
    }
    
    var color: Color {
        switch self {
        case .pending:
            return .orange
        case .accepted:
            return .green
        case .denied:
            return .red
        case .cancelled:
            return .gray
        case .cancellationRequested:
            return .blue
        }
    }
}

struct RentalProperty: Codable, Identifiable {
    let id: String
    let title: String
    let images: [String]
    let price: Double
    let pricingFrequency: PricingFrequency
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title, images, price, pricingFrequency
    }
}

struct RentalUser: Codable, Identifiable, Equatable {
    let id: String
    let firstName: String?
    let lastName: String?
    let email: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case firstName, lastName, email
    }
}

struct Rental: Codable, Identifiable {
    let id: String
    let property: RentalProperty
    let tenant: RentalUser
    let owner: RentalUser
    var status: RentalStatus
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case property, tenant, owner, status
    }
}

struct ConversationRentalProperty: Codable, Identifiable {
    let id: String
    let title: String
    let images: [String]
    let price: Double
    let pricingFrequency: PricingFrequency
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title, images, price, pricingFrequency
    }
}

struct ConversationRental: Codable {
    let property: ConversationRentalProperty
}

struct Conversation: Codable, Identifiable {
    let id: String
    let rental: ConversationRental
    let participants: [RentalUser]
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case rental, participants, createdAt, updatedAt
    }
}

struct Reaction: Codable, Identifiable, Equatable {
    var id: String { user.id }
    let emoji: String
    let user: RentalUser
}

struct Message: Codable, Identifiable, Equatable {
    let id: String
    let conversation: String
    let sender: RentalUser
    let receiver: String
    var text: String?
    var imageUrl: String?
    var isEdited: Bool?
    var reactions: [Reaction]
    let createdAt: String
    let updatedAt: String
    
    var canBeEdited: Bool {
        guard imageUrl == nil, let date = ISO8601DateFormatter().date(from: createdAt) else {
            return false
        }
        return Date().timeIntervalSince(date) < 120
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case conversation, sender, receiver, text, imageUrl, isEdited, reactions, createdAt, updatedAt
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

struct PropertiesResponse: Codable {
    let success: Bool
    let properties: [Property]
}

struct PropertyResponse: Codable {
    let success: Bool
    let property: Property
}

struct RentalsResponse: Codable {
    let success: Bool
    let rentals: [Rental]
}

struct RentalResponse: Codable {
    let success: Bool
    let rental: Rental
}

struct ConversationsResponse: Codable {
    let success: Bool
    let conversations: [Conversation]
}

struct ConversationResponse: Codable {
    let success: Bool
    let conversation: Conversation
}

struct MessagesResponse: Codable {
    let success: Bool
    let messages: [Message]
}

struct MessageServiceResponse: Codable {
    let success: Bool
    let message: Message
}

struct UploadResponse: Codable {
    let success: Bool
    let imageUrl: String
}

struct RegistrationOTPRequest: Encodable {
    let firstName: String
    let lastName: String
    let email: String
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
    let userType: UserType
}

struct UpdateProfileRequest: Encodable {
    let firstName: String?
    let lastName: String?
}

struct CreatePropertyRequest: Encodable {
    let title: String
    let description: String
    let address: String
    let images: [String]
    let price: Double
    let pricingFrequency: PricingFrequency
    let allowBargaining: Bool
}

struct UpdatePropertyRequest: Encodable {
    let title: String?
    let description: String?
    let address: String?
    let images: [String]?
    let price: Double?
    let pricingFrequency: PricingFrequency?
    let allowBargaining: Bool?
    let status: PropertyStatus?
}

struct CreateRentalRequest: Encodable {
    let propertyId: String
}

struct UpdateRentalStatusRequest: Encodable {
    let status: RentalStatus
}

struct InitiateChatRequest: Encodable {
    let rentalId: String
}

struct SendMessageRequest: Encodable {
    let text: String?
    let imageUrl: String?
}

struct EditMessageRequest: Encodable {
    let text: String
}

struct ReactToMessageRequest: Encodable {
    let emoji: String
}
