//
//  RMEndpoint.swift
//  RickAndMortyRA
//
//  Created by MacOS on 3.10.2023.
//

import Foundation

@frozen enum RMEndpoint: String, CaseIterable, Hashable{
    case character
    case location
    case episode
}
