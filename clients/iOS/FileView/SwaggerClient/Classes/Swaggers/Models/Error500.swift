//
// Error500.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** internal server error */

open class Error500: Codable {

    public var error: String?


    
    public init(error: String?) {
        self.error = error
    }
    

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: String.self)

        try container.encodeIfPresent(error, forKey: "error")
    }

    // Decodable protocol methods

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: String.self)

        error = try container.decodeIfPresent(String.self, forKey: "error")
    }
}

