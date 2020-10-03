//
//  JSON+Extensions.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez on 30/09/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import Foundation

extension Dictionary where Key == String {
    func bool(for key: String) -> Bool? {
        self[key] as? Bool
    }

    func double(for key: String) -> Double? {
        self[key] as? Double
    }

    func int(for key: String) -> Int? {
        self[key] as? Int
    }

    func string(for key: String) -> String? {
        self[key] as? String
    }
    
    func date(for key: String) -> Date? {
        self[key] as? Date
    }
}

@dynamicMemberLookup
struct JSON: RandomAccessCollection {
    var value: Any?
    var startIndex: Int { array.startIndex }
    var endIndex: Int { array.endIndex }

    init(string: String) throws {
        let data = Data(string.utf8)
        value = try JSONSerialization.jsonObject(with: data)
    }

    init(value: Any?) {
        self.value = value
    }

    var optionalBool: Bool? {
        value as? Bool
    }

    var optionalDouble: Double? {
        value as? Double
    }

    var optionalInt: Int? {
        value as? Int
    }

    var optionalString: String? {
        value as? String
    }
    
    var optionalDate: Date? {
        value as? Date
    }

    var bool: Bool {
        optionalBool ?? false
    }

    var double: Double {
        optionalDouble ?? 0
    }

    var int: Int {
        optionalInt ?? 0
    }

    var string: String {
        optionalString ?? ""
    }
    
    var date: Date {
        optionalDate ?? Date()
    }

    var optionalArray: [JSON]? {
        let converted = value as? [Any]
        return converted?.map { JSON(value: $0) }
    }

    var optionalDictionary: [String: JSON]? {
        let converted = value as? [String: Any]
        return converted?.mapValues { JSON(value: $0) }
    }

    var array: [JSON] {
        optionalArray ?? []
    }

    var dictionary: [String: JSON] {
        optionalDictionary ?? [:]
    }

    subscript(index: Int) -> JSON {
        optionalArray?[index] ?? JSON(value: nil)
    }

    subscript(key: String) -> JSON {
        optionalDictionary?[key] ?? JSON(value: nil)
    }

    subscript(dynamicMember key: String) -> JSON {
        optionalDictionary?[key] ?? JSON(value: nil)
    }
}
