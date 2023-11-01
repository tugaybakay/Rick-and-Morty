//
//  RMCharacterCollectionViewCellViewModel.swift
//  RickAndMortyRA
//
//  Created by MacOS on 6.10.2023.
//

import Foundation

final class RMCharacterCollectionViewCellViewModel: Hashable, Equatable {
    
    static func == (lhs: RMCharacterCollectionViewCellViewModel, rhs: RMCharacterCollectionViewCellViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(characterName)
        hasher.combine(characterStatus)
        hasher.combine(characterImageUrl)
    }
    
    
    let characterName: String?
    private let characterStatus: RMCharacterStatus
    let characterImageUrl: URL?
    
    var characterStatusText: String {
        return "Status: \(characterStatus.rawValue)"
    }
    
    init(name: String?,status: RMCharacterStatus,imageUrl: URL?) {
        self.characterName = name
        self.characterStatus = status
        self.characterImageUrl = imageUrl
    }
    
    func fetchImage(completion: @escaping (Result<Data,Error>) -> Void) {
        guard let url = characterImageUrl else {
            completion(.failure(URLError(.badURL)))
            return
        }
        RMImageLoader.shared.downloadImage(with: url, completion: completion)
    }
}
