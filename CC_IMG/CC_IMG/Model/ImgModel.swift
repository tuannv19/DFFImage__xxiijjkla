// To parse the JSON, add this file to your project and do:
//
//   let imgModel = try? newJSONDecoder().decode(ImgModel.self, from: jsonData)

import Foundation

typealias ImgModel = [ImgModelElement]

struct ImgModelElement: Codable {
    let id, title: String
    let url: String
    let images: String
    let category: Int
    let tags: JSONNull?
    let width, height, status, createdTime: Int
    let type, likeCount, viewCount, shareCount: Int
    let description: JSONNull?
    
    enum CodingKeys: String, CodingKey {
        case id, title, url, images, category, tags, width, height, status
        case createdTime = "created_time"
        case type, likeCount, viewCount, shareCount, description
    }
}

// MARK: Encode/decode helpers

class JSONNull: Codable, Hashable {
    
    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }
    
    public var hashValue: Int {
        return 0
    }
    
    public init() {}
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
