//
//  Model.swift
//  fancertification
//
//  Created by 유지상 on 2022/05/05.
//

struct FunctionResponse {
    let status: Int
    let message: String
}

struct FirestoreResponse: Codable {
    let celeb: [Celeb]
}

struct Celeb: Codable {
    let account: String
    let count: Int
    let platform: Int
    let recent: String
    let since: String
    let title: String
    let url: String
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
