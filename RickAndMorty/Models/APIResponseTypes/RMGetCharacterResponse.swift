//
//  RMGetCharacterResponse.swift
//  RickAndMortyRA
//
//  Created by MacOS on 6.10.2023.
//

import Foundation

struct RMGetAllCharatcerResponse: Codable {
    let info: Info
    let results: [RMCharacter]
}


struct Info: Codable {
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?
}
