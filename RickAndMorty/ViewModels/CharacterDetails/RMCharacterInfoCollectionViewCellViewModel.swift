//
//  RMCharacterInfoCollectionViewCellViewModel.swift
//  RickAndMortyRA
//
//  Created by MacOS on 12.10.2023.
//

import UIKit

final class RMCharacterInfoCollectionViewCellViewModel {
    
    private let type: TitleType
    private let value: String
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSZ"
        formatter.timeZone = .current
        return formatter
    }()
    
    static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.timeZone = .autoupdatingCurrent
        return formatter
    }()
    
    var title: String {
        return type.displaytitle
    }
    
    var displayValue: String{
        if value.isEmpty { return "None"}
        if let date = Self.dateFormatter.date(from: value), type == .created {
            return Self.shortDateFormatter.string(from: date)
        }
        return value
    }
    
    var iconImage: UIImage? {
        return type.iconImage
    }
    
    var tintColor: UIColor {
        return type.tintColor
    }

    enum TitleType: String {
        case status
        case gender
        case type
        case species
        case origin
        case created
        case location
        case episodeCount
        
        var tintColor: UIColor {
            switch self {
            case .status:
                return .systemRed
            case .gender:
                return .systemBlue
            case .type:
                return .systemPurple
            case .species:
                return .systemPink
            case .origin:
                return .systemOrange
            case .created:
                return .systemCyan
            case .location:
                return .systemYellow
            case .episodeCount:
                return .systemMint
            }
        }
        
        var displaytitle: String {
            switch self {
            case .status,.gender,.type,.species,.origin,.created,.location:
                return rawValue.uppercased()
            case .episodeCount:
                return "EPISODE COUNT"
            }
        }
        
        var iconImage: UIImage? {
            switch self {
            case .status:
                return UIImage(systemName: "bell")
            case .gender:
                return UIImage(systemName: "bell")
            case .type:
                return UIImage(systemName: "bell")
            case .species:
                return UIImage(systemName: "bell")
            case .origin:
                return UIImage(systemName: "bell")
            case .created:
                return UIImage(systemName: "bell")
            case .location:
                return UIImage(systemName: "bell")
            case .episodeCount:
                return UIImage(systemName: "bell")
            }
        }
    }
    
    init( value: String,type: TitleType) {
        self.value = value
        self.type = type
    }
}
