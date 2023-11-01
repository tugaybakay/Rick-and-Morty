//
//  RMLocationDetailViewViewModel.swift
//  RickAndMortyRA
//
//  Created by MacOS on 24.10.2023.
//

import Foundation


protocol RMLocationDetailViewViewModelDelegate: AnyObject {
    func didFetchLocationDetails()
}

final class RMLocationDetailViewViewModel {
    
    private let endpointUrl: URL?
    
    weak var delegate: RMLocationDetailViewViewModelDelegate?
    
    private var dataTuple: (location: RMLocation,characters: [RMCharacter])? {
        didSet {
            createCellViewModels()
            delegate?.didFetchLocationDetails()
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
        fetchLocationData()
    }
    
    func fetchLocationData() {
        guard let url = endpointUrl, let request = RMRequest(url: url) else { return }
        RMService.shared.execute(request, expecting: RMLocation.self) { [weak self] result in
            switch result {
            case .success(let success):
                self?.fetchRelatedCharacters(location: success)
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
    
    private func fetchRelatedCharacters(location: RMLocation) {
        let characterUrls: [URL] = location.residents.compactMap({
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
            self?.dataTuple = (location: location,characters: characters)
        }
    }
    
    private func createCellViewModels() {
        guard let dataTuple = dataTuple else {return}
        let location = dataTuple.location
        let characters = dataTuple.characters
        
        var createdString = location.created
        if let createdDate = RMCharacterInfoCollectionViewCellViewModel.dateFormatter.date(from: location.created) {
            createdString = RMCharacterInfoCollectionViewCellViewModel.shortDateFormatter.string(from: createdDate)
        }
        
        cellViewModels = [.information(viewModels: [.init(title: "Location Name", value: location.name),
                                                    .init(title: "Type", value: location.type),
                                              .init(title: "Dimension", value: location.dimension),
                                              .init(title: "Created", value: createdString)]),
                    .character(viewModel: characters.compactMap({
                        return RMCharacterCollectionViewCellViewModel(name: $0.name, status: $0.status, imageUrl: URL(string: $0.image))
                    }))]
    }
    
}
