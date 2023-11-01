//
//  RMCharacter.swift
//  RickAndMortyRA
//
//  Created by MacOS on 6.10.2023.
//

import Foundation

struct RMCharacter: Codable {
    let id: Int
    let name: String
    let status: RMCharacterStatus
    let species: String
    let type: String
    let gender: RMCharacterGender
    let image: String
    let episode: [String]
    let url: String
    let created: String
    let origin: RMOrigin
    let location: RMSingleLocation
}

enum RMCharacterStatus: String, Codable {
    case alive = "Alive"
    case dead = "Dead"
    case unknown = "unknown"
}

enum RMCharacterGender: String,Codable {
    case male = "Male"
    case female = "Female"
    case genderless = "Genderless"
    case unknown = "unknown"
}
