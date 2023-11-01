//
//  RMGetLocationResponce.swift
//  RickAndMortyRA
//
//  Created by MacOS on 24.10.2023.
//

import Foundation

struct RMGetLocationResponse: Codable {
    let info: Info
    let results: [RMLocation]
}
