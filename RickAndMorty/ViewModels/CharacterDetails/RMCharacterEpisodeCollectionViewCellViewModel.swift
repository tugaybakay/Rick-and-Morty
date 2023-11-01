//
//  RMCharacterEpisodeCollectionViewCellViewModel.swift
//  RickAndMortyRA
//
//  Created by MacOS on 12.10.2023.
//

import Foundation

protocol RMEpisodeDataRender {
    var name: String { get }
    var air_date: String { get }
    var episode: String { get }
}

final class RMCharacterEpisodeCollectionViewCellViewModel: Hashable, Equatable {
    
    
    private let episodeUrl: URL?
    private var isFetching = false
    private var episode: RMEpisode? {
        didSet {
            guard let model = episode else { return }
            dataBlock?(model)
        }
    }
    private var dataBlock: ((RMEpisodeDataRender) -> Void)?
    
    init(episodeUrl: URL?) {
        self.episodeUrl = episodeUrl
    }
    
    func registerForData(_ block: @escaping(RMEpisodeDataRender) -> Void) {
        self.dataBlock = block
    }
    
    func fetchEpisode() {
        guard !isFetching else {
            if let model = episode {
                dataBlock?(model)
            }
            return
        }
        
        guard let url = episodeUrl, let rmRequest = RMRequest(url: url) else { return }
        isFetching = true
        RMService.shared.execute(rmRequest, expecting: RMEpisode.self) { [weak self] result in
            switch result {
            case .success(let model):
                DispatchQueue.main.async {
                    self?.episode = model
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.episodeUrl?.absoluteString ?? "")
    }
    
    static func == (lhs: RMCharacterEpisodeCollectionViewCellViewModel, rhs: RMCharacterEpisodeCollectionViewCellViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    
}
