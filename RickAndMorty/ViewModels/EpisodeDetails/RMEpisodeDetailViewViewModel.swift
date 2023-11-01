//
//  RMEpisodeDetailViewViewModel.swift
//  RickAndMortyRA
//
//  Created by MacOS on 15.10.2023.
//

import Foundation

protocol RMEpisodeDetailViewViewModelDelegate: AnyObject {
    func didFetchEpisodeDetails()
}

final class RMEpisodeDetailViewViewModel {
    
    private let endpointUrl: URL?
    
    weak var delegate: RMEpisodeDetailViewViewModelDelegate?
    
    private var dataTuple: (episode: RMEpisode,characters: [RMCharacter])? {
        didSet {
            createCellViewModels()
            delegate?.didFetchEpisodeDetails()
        }
    }
    
    enum SectionType {
        case information(viewModels: [RMEpisodeInfoCollectionViewCellViewModel])
        case character(viewModel: [RMCharacterCollectionViewCellViewModel])
    }
    
    internal private(set) var cellViewModels: [SectionType] = []
    
    //MARK: - Init method
    
    init(url: URL?) {
        self.endpointUrl = url
        fetchEpisodeData()
    }
    
    func fetchEpisodeData() {
        guard let url = endpointUrl, let request = RMRequest(url: url) else { return }
        RMService.shared.execute(request, expecting: RMEpisode.self) { [weak self] result in
            switch result {
            case .success(let success):
                self?.fetchRelatedCharacters(episode: success)
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
    
    func character(at index: Int) -> RMCharacter? {
        guard let dataTuple = dataTuple else {
            return nil
        }
        return dataTuple.characters[index]
    }
    
    private func fetchRelatedCharacters(episode: RMEpisode) {
        let characterUrls: [URL] = episode.characters.compactMap({
            return URL(string: $0)
        })
        let requests: [RMRequest] = characterUrls.compactMap({
            return RMRequest(url: $0)
        })
        
        let group = DispatchGroup()
        var characters: [RMCharacter] = []
        for request in requests {
            group.enter()
            RMService.shared.execute(request, expecting: RMCharacter.self) { result in
                defer {
                    group.leave()
                }
                switch result {
                case .success(let model):
                    characters.append(model)
                case .failure:
                    break
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.dataTuple = (episode: episode,characters: characters)
        }
    }
    
    private func createCellViewModels() {
        guard let dataTuple = dataTuple else {return}
        let episode = dataTuple.episode
        let characters = dataTuple.characters
        
        var createdString = episode.created
        if let createdDate = RMCharacterInfoCollectionViewCellViewModel.dateFormatter.date(from: episode.created) {
            createdString = RMCharacterInfoCollectionViewCellViewModel.shortDateFormatter.string(from: createdDate)
        }
        
        cellViewModels = [.information(viewModels: [.init(title: "Name", value: episode.name),
                                              .init(title: "Air date", value: episode.air_date),
                                              .init(title: "Episode", value: episode.episode),
                                              .init(title: "Created", value: createdString)]),
                    .character(viewModel: characters.compactMap({
                        return RMCharacterCollectionViewCellViewModel(name: $0.name, status: $0.status, imageUrl: URL(string: $0.image))
                    }))]
    }
    
}
