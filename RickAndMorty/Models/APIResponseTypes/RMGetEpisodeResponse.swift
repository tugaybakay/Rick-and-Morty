//
//  RMGetEpisodeResponse.swift
//  RickAndMortyRA
//
//  Created by MacOS on 16.10.2023.
//

import Foundation

struct RMGetAllEpisodesResponse: Codable {
    let info: Info
    let results: [RMEpisode]
}

