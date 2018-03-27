//
// Key.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** Token key */

open class Key: Codable {

    public var key: String?


    
    public init(key: String?) {
        self.key = key
    }
    

    // Encodable protocol methods

    public func encode(to encoder: Encoder) throws {

        var container = encoder.container(keyedBy: String.self)

        try container.encodeIfPresent(key, forKey: "key")
    }

    // Decodable protocol methods

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: String.self)

        key = try container.decodeIfPresent(String.self, forKey: "key")
    }
}

