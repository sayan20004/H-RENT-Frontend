//
//  APIError.swift
//  HRENT
//
//  Created by Sayan  Maity  on 31/10/25.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(statusCode: Int, message: String)
    case decodingError(Error)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The server URL is invalid."
        case .requestFailed(_, let message):
            return message
        case .decodingError:
            return "Failed to decode the server response."
        case .unknown(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
}

struct APIErrorResponse: Codable {
    let message: String
}
