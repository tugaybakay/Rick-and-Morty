//
//  RMCharacterPhotoCollectionViewCellViewModel.swift
//  RickAndMortyRA
//
//  Created by MacOS on 12.10.2023.
//

import Foundation

final class RMCharacterPhotoCollectionViewCellViewModel {
    
    private let imageUrl: URL?
    
    init(imageUrl: URL?) {
        self.imageUrl = imageUrl
    }
    
    func fetchImage(completion: @escaping (Result<Data,Error>) -> Void) {
        guard let imageUrl = imageUrl else {
            completion(.failure(URLError(.badURL)))
            return
        }
        RMImageLoader.shared.downloadImage(with: imageUrl, completion: completion)
    }
}
