//
//  RMSearchViewViewModel.swift
//  RickAndMortyRA
//
//  Created by MacOS on 24.10.2023.
//

import Foundation

final class RMSearchViewViewModel {
    
    private var optionMap: [DynamicOption:String] = [:]
    private var optionMapBlock: (((DynamicOption,String)) -> Void)?
    private var searchResultHandler: ((RMSearchResultViewModel) -> Void)?
    private var noResultsHandler: (() -> Void)?
    private var searchText = ""
    
    private var searchResultModel: Codable?
    
    let config: RMSearchViewController.Config
    
    init(config: RMSearchViewController.Config ) {
        self.config = config
        
    }
    
    func registerSearchResultHandler(_ block: @escaping (RMSearchResultViewModel) -> Void ) {
        self.searchResultHandler = block
    }
    
    func registerNoResultsHandler(_ block: @escaping () -> Void ) {
        self.noResultsHandler = block
    }
    
    func set(value: String, for option: DynamicOption) {
        optionMap[option] = value
        let tuple = (option,value)
        optionMapBlock?(tuple)
    }
    
    func registerOptionChangeBlock(_ block: @escaping ((DynamicOption,String)) -> Void) {
        self.optionMapBlock = block
    }
    
    func set(query text: String) {
        self.searchText = text
    }
    
    func executeSearch() {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        var queryParams: [URLQueryItem] = [URLQueryItem(name: "name", value: searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))]
        
        queryParams.append(contentsOf: optionMap.enumerated().compactMap({ _, value in
            let key = value.key
            let value = value.value
            return URLQueryItem(name: key.queryArgument, value: value)
        }))
        
        let request = RMRequest(endpoint: config.type.endpoint ,queryParameters: queryParams)
        //        print(request.url?.absoluteString)
        
        switch config.type {
        case .character: makeSearchAPICall(RMGetAllCharatcerResponse.self, request: request)
        case .episode: makeSearchAPICall(RMGetAllEpisodesResponse.self, request: request)
        case .location: makeSearchAPICall(RMGetLocationResponse.self, request: request)
        }
        
    }
    
    private func makeSearchAPICall<T: Codable>(_ type: T.Type, request: RMRequest) {
        RMService.shared.execute(request, expecting: type) { [weak self] result in
            switch result {
            case .success(let model):
                self?.processSearchResults(model: model)
    
            case .failure:
                self?.handleNoResult()
            }
        }
    }
    
    private func processSearchResults(model: Codable) {
        var resultVM: RMSearchResultType?
        var nextUrl: String?
        RMSearchResultViewModel.characters = []
        RMSearchResultViewModel.episodes = []
        RMSearchResultViewModel.locations = []
        if let characterResults = model as? RMGetAllCharatcerResponse {
            RMSearchResultViewModel.characters.append(contentsOf: characterResults.results)
            resultVM = .characters(characterResults.results.compactMap({
                return RMCharacterCollectionViewCellViewModel(name: $0.name, status: $0.status, imageUrl: URL(string: $0.image))
            }))
            nextUrl = characterResults.info.next
        }
        else if let episodeResults = model as? RMGetAllEpisodesResponse {
            RMSearchResultViewModel.episodes.append(contentsOf: episodeResults.results)
            resultVM = .episodes(episodeResults.results.compactMap({
                return RMCharacterEpisodeCollectionViewCellViewModel(episodeUrl: URL(string: $0.url))
            }))
            nextUrl = episodeResults.info.next
        }
        else if let locationResults = model as? RMGetLocationResponse {
            RMSearchResultViewModel.locations.append(contentsOf: locationResults.results)
            resultVM = .locations(locationResults.results.compactMap({
                return RMLocationTableViewCellViewModel(location: $0)
            }))
            nextUrl = locationResults.info.next
        }
        
        if let result = resultVM {
            self.searchResultModel = model
            let vm = RMSearchResultViewModel(result: result,next: nextUrl)
            self.searchResultHandler?(vm)
        }
        else { // Error
            handleNoResult()
        }
        
    }
    
    private func handleNoResult() {
        noResultsHandler?()
    }
   
    
    func locationSearchResult(at index: Int) -> RMLocation? {
        return RMSearchResultViewModel.locations[index]
    }

    func characterSearchResult(at index: Int) -> RMCharacter? {
        return RMSearchResultViewModel.characters[index]
    }

     func episodeSearchResult(at index: Int) -> RMEpisode? {
         return RMSearchResultViewModel.episodes[index]
        }
}



