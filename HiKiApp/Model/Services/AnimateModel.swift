//
//  AnimateModel.swift
//  NaMuApp
//
//  Created by 정성윤 on 2/6/25.
//

import Foundation

struct AnimateModel: Decodable, Hashable {
    let data: [AnimateData]
}

struct AnimateData: Decodable, Hashable {
    let mal_id: Int
    let url: String
    let images: AnimateImages
    let title: String
    let type: String?
    let synopsis: String?
    let score: Double?
    let rank: Int?
    let title_english: String?
    let trailer: AnimateTrailer
    let genres: [AnimateGenre]?
    
    //TODO: 디코딩 전략
}

struct AnimateGenre: Decodable, Hashable {
    let name: String
}

struct AnimateTrailer: Decodable, Hashable {
    let embed_url: String?
    let youtube_id: String?
    let url: String?
    
    //TODO: 디코딩 전략
}

struct AnimateImages: Decodable, Hashable {
    let jpg: AnimateJpg
}

struct AnimateJpg: Decodable, Hashable {
    let image_url: String
    let small_image_url: String
    let large_image_url: String
}

struct AnimateReviewModel: Decodable {
    let data: [ReviewData]
}

struct ReviewData: Decodable {
    let score: Int
    let date: String
    let review: String
    let is_spoiler: Bool
    let user: ReviewUser
    let entry: ReviewEntry
}

struct ReviewUser: Decodable {
    let username: String
}

struct ReviewEntry: Decodable {
    let mal_id: Int
    let title: String
    let images: AnimateImages
}
