//
//  RMEpisode.swift
//  RickAndMorty
//
//  Created by MacOS on 3.10.2023.
//

import Foundation

struct RMEpisode: Codable, RMEpisodeDataRender{
    let id: Int
    let name: String
    let air_date: String
    let episode: String
    let characters: [String]
    let url: String
    let created: String
}
