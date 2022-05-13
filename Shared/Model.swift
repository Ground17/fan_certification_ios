//
//  Model.swift
//  fancertification
//
//  Created by 유지상 on 2022/05/05.
//

import Firebase
import UIKit

struct FunctionResponse {
    let status: Int
    let message: String
}

//struct FirestoreResponse: Codable {
//    let celeb: [Celeb]
//}

struct Celeb: Codable {
    let account: String
    let platform: String
    var count: Int
    var recent: Date
    let since: Date
    var title: String
    var url: String
    
    init(dictionary: [String: Any]) {
        self.account = dictionary["account"] as? String ?? ""
        self.platform = dictionary["platform"] as? String ?? ""
        self.count = dictionary["count"] as? Int ?? 0
        self.recent = (dictionary["recent"] as? Timestamp)?.dateValue() ?? Date()
        self.since = (dictionary["since"] as? Timestamp)?.dateValue() ?? Date()
        self.title = dictionary["title"] as? String ?? ""
        self.url = dictionary["url"] as? String ?? ""
    }
}

struct Response: Codable {
    let items: [Item]
}

struct Item: Codable {
    let snippet: Snippet
}

struct Snippet: Codable {
    let channelId: String
    let title: String
    let description: String
    let thumbnails: Thumbnail
}

struct Thumbnail: Codable {
    let `default`: profileURL
}

struct profileURL: Codable {
    let url: String
}
