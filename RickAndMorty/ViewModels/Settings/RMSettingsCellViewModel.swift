//
//  RMSettingsCellViewViewModel.swift
//  RickAndMortyRA
//
//  Created by MacOS on 24.10.2023.
//

import UIKit

struct RMSettingsCellViewModel: Identifiable {
        let id = UUID()
        
    var image: UIImage? {
        return type.iconImage
    }
    var title: String {
        return type.displayTitle
    }
    var iconContainerColor: UIColor {
        return type.iconContainerColor
    }
    
    let onTapHandler: (RMSettingsOption) -> Void
    
    let type: RMSettingsOption
    
    init(type: RMSettingsOption, onTapHandler: @escaping (RMSettingsOption) -> Void) {
        self.type = type
        self.onTapHandler = onTapHandler
    }
}
