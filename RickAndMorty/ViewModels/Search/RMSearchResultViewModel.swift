//
//  RMSearchResultType.swift
//  RickAndMortyRA
//
//  Created by MacOS on 26.10.2023.
//

import Foundation

enum RMSearchResultType {
    case characters([RMCharacterCollectionViewCellViewModel])
    case episodes([RMCharacterEpisodeCollectionViewCellViewModel])
    case locations([RMLocationTableViewCellViewModel])
}

final class RMSearchResultViewModel {
    internal private(set) var result: RMSearchResultType
    var next: String?
    
    var shouldShowLoadMoreIndicator: Bool {
        return next != nil
    }
    
    var viewModels: [any Hashable] = []
    
    static var characters: [RMCharacter] = []
    static var locations: [RMLocation] = []
    static var episodes: [RMEpisode] = []
    
    private(set) var isLoadingMoreResults = false
        
    init(result: RMSearchResultType, next: String?) {
        self.result = result
        self.next = next
    }
    
    func fetchAddtionalLocations(completion: @escaping ([RMLocationTableViewCellViewModel]) -> Void) {
        guard !isLoadingMoreResults else {return}
        guard let urlString = next, let url = URL(string: urlString) else { return }
        
        isLoadingMoreResults = true
        guard let request = RMRequest(url: url) else {
            isLoadingMoreResults = false
            print("Failed to creat request")
            return
        }

        RMService.shared.execute(request, expecting: RMGetLocationResponse.self) { [weak self] result in
            switch result {
            case .success(let responseModel):
                let moreResult = responseModel.results
                self?.next = responseModel.info.next
                RMSearchResultViewModel.locations.append(contentsOf: moreResult)
                
                let additionalLocations = moreResult.compactMap({
                    return RMLocationTableViewCellViewModel(location: $0)
                })
                var newResults: [RMLocationTableViewCellViewModel] = []
                switch self?.result {
                case .locations(let existingResults):
                    newResults = existingResults + additionalLocations
                    self?.result = .locations(newResults)
                case .characters,.episodes,.none:
                    break
                }
                
                DispatchQueue.main.async {
                    self?.isLoadingMoreResults = false
                    completion(newResults)
                }
            case .failure(let error):
                self?.isLoadingMoreResults = false
                print(error)
            }
        }
    }
    
    func fetchAddtionalResults(completion: @escaping ([any Hashable]) -> Void) {
        guard !isLoadingMoreResults else {return}
        guard let urlString = next, let url = URL(string: urlString) else { return }
        
        
        isLoadingMoreResults = true
        guard let request = RMRequest(url: url) else {
            isLoadingMoreResults = false
            print("Failed to creat request")
            return
        }
        
        switch result {
        case .characters(let existingResults):
//            print("request url: \(request.url!.absoluteString)")
            RMService.shared.execute(request, expecting: RMGetAllCharatcerResponse.self) { [weak self] response in
                switch response {
                case .success(let responseModel):
                    let moreResult = responseModel.results
                    self?.next = responseModel.info.next
                    RMSearchResultViewModel.characters.append(contentsOf: responseModel.results)
                    let additionalCharacters = moreResult.compactMap({

                        return RMCharacterCollectionViewCellViewModel(name: $0.name, status: $0.status, imageUrl: URL(string: $0.image))
                    })
                    let newResults = existingResults + additionalCharacters
                    print("count: \(newResults.count)")
                    self?.result = .characters(newResults)
                    
                    DispatchQueue.main.async {
                        self?.isLoadingMoreResults = false
                        completion(newResults)
                    }
                case .failure(let error):
                    self?.isLoadingMoreResults = false
                    print(error)
                }
            }
        case .episodes(let existingResults):
            RMService.shared.execute(request, expecting: RMGetAllEpisodesResponse.self) { [weak self] response in
                switch response {
                case .success(let responseModel):
                    let moreResult = responseModel.results
                    self?.next = responseModel.info.next
                    RMSearchResultViewModel.episodes.append(contentsOf: moreResult)
                    
                    let additionalLocations = moreResult.compactMap({
                        return RMCharacterEpisodeCollectionViewCellViewModel(episodeUrl: URL(string: $0.url))
                    })
                    let newResults = existingResults + additionalLocations
                    self?.viewModels = newResults
                    self?.result = .episodes(newResults)
                    
                    DispatchQueue.main.async {
                        self?.isLoadingMoreResults = false
                        completion(newResults)
                    }
                case .failure(let error):
                    self?.isLoadingMoreResults = false
                    print(error)
                }
            }
        case .locations:
            break
        }
        
    }

}




