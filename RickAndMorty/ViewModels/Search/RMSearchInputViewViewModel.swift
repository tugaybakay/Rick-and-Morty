//
//  RMSearchInputViewViewModel.swift
//  RickAndMortyRA
//
//  Created by MacOS on 24.10.2023.
//

import Foundation

enum DynamicOption: String {
    case status = "Status"
    case gender = "Gender"
    case locationType = "Location Type"
    
    var queryArgument: String {
        switch self {
        case .status:
            return "status"
        case .gender:
            return "gender"
        case .locationType:
            return "type"
        }
    }
    
    var choices: [String] {
        switch self {
        case .status:
            return ["alive","dead","unknown"]
        case .gender:
            return ["male","female","genderless","unknown"]
        case .locationType:
            return ["cluster","planet","microverse"]
        }
    }
}

final class RMSearchInputViewViewModel {
    
    private let type: RMSearchViewController.Config.ConfigType
    
    init(type: RMSearchViewController.Config.ConfigType) {
        self.type = type
    }
    var hasDynamicOptions: Bool {
        switch self.type {
        case .character,.location:
            return true
        case .episode:
            return false
        }
    }
    
    var options: [DynamicOption] {
        switch self.type {
        case .character:
            return [.status,.gender]
        case .location:
            return [.locationType]
        case .episode:
            return []
        }
    }
    
    var searchPlaceHolderText: String {
        switch self.type {
        case .character:
            return "Character Name"
        case .location:
            return "Location Name"
        case .episode:
            return "Episode Title"
        }
    }
}
