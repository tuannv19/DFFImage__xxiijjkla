// To parse the JSON, add this file to your project and do:
//
//   let imgModel = try ImgModel(json)
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseImgModel { response in
//     if let imgModel = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

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

// MARK: Convenience initializers and mutators

extension ImgModelElement {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(ImgModelElement.self, from: data)
    }
    
    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func with(
        id: String? = nil,
        title: String? = nil,
        url: String? = nil,
        images: String? = nil,
        category: Int? = nil,
        tags: JSONNull?? = nil,
        width: Int? = nil,
        height: Int? = nil,
        status: Int? = nil,
        createdTime: Int? = nil,
        type: Int? = nil,
        likeCount: Int? = nil,
        viewCount: Int? = nil,
        shareCount: Int? = nil,
        description: JSONNull?? = nil
        ) -> ImgModelElement {
        return ImgModelElement(
            id: id ?? self.id,
            title: title ?? self.title,
            url: url ?? self.url,
            images: images ?? self.images,
            category: category ?? self.category,
            tags: tags ?? self.tags,
            width: width ?? self.width,
            height: height ?? self.height,
            status: status ?? self.status,
            createdTime: createdTime ?? self.createdTime,
            type: type ?? self.type,
            likeCount: likeCount ?? self.likeCount,
            viewCount: viewCount ?? self.viewCount,
            shareCount: shareCount ?? self.shareCount,
            description: description ?? self.description
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

extension Array where Element == ImgModel.Element {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(ImgModel.self, from: data)
    }
    
    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
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

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}

// MARK: - Alamofire response handlers

extension DataRequest {
    fileprivate func decodableResponseSerializer<T: Decodable>() -> DataResponseSerializer<T> {
        return DataResponseSerializer { _, response, data, error in
            guard error == nil else { return .failure(error!) }
            
            guard let data = data else {
                return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
            }
            
            return Result { try newJSONDecoder().decode(T.self, from: data) }
        }
    }
    
    @discardableResult
    fileprivate func responseDecodable<T: Decodable>(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: decodableResponseSerializer(), completionHandler: completionHandler)
    }
    
    @discardableResult
    func responseImgModel(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<ImgModel>) -> Void) -> Self {
        return responseDecodable(queue: queue, completionHandler: completionHandler)
    }
}
