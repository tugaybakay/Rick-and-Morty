//
//  RMLocationViewViewModel.swift
//  RickAndMortyRA
//
//  Created by MacOS on 24.10.2023.
//

import Foundation

protocol RMLocationViewViewModelDelegate: AnyObject {
    func didFetchInitialLocations()
}

final class RMLocationViewViewModel {

    private var locations: [RMLocation] = [] {
        didSet {
            for location in locations {
                let cellViewModel = RMLocationTableViewCellViewModel(location: location)
                if !cellViewModels.contains(cellViewModel) {
                    cellViewModels.append(cellViewModel)
                }
            }
        }
    }
    
    private var didFinishPaginationBlock: (() -> Void)?
    
    private(set) var cellViewModels: [RMLocationTableViewCellViewModel] = []
    
    weak var delegate: RMLocationViewViewModelDelegate?
    
    var apiInfo: Info?
    
    var shouldShowLoadMoreIndıcator: Bool {
        return apiInfo != nil
    }
    
    var isLoadingMoreLocation = false
    
    private var hasMoreLocation: Bool {
        return false
    }
    
    init() {}
    
    func location(at index: Int) -> RMLocation? {
        guard index < locations.count else { return nil}
        return locations[index]
    }
    
    func fetchLocations() {
        let request = RMRequest(endpoint: .location)
        RMService.shared.execute(request, expecting: RMGetLocationResponse.self) { [weak self] result in
            switch result {
            case .success(let response):
                self?.apiInfo = response.info
                self?.locations = response.results
                DispatchQueue.main.async {
                    self?.delegate?.didFetchInitialLocations()
                }
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    func fetchAddtionalLocations() {
        
        guard !isLoadingMoreLocation,let urlString = apiInfo?.next, let url = URL(string: urlString) else { return }
        
        
        isLoadingMoreLocation = true
        guard let request = RMRequest(url: url) else {
            isLoadingMoreLocation = false
            print("Failed to creat request")
            return
        }
//        print(url.absoluteString)
        
        RMService.shared.execute(request, expecting: RMGetLocationResponse.self) { [weak self] result in
            switch result {
            case .success(let responseModel):
                let moreResult = responseModel.results
                self?.locations.append(contentsOf: moreResult)
                self?.apiInfo = responseModel.info
                
//                print(info.next)
                self?.cellViewModels.append(contentsOf: moreResult.compactMap({
                    return RMLocationTableViewCellViewModel(location: $0)
                }))
                
                
                DispatchQueue.main.async {
                    self?.isLoadingMoreLocation = false
                    self?.didFinishPaginationBlock?()
                }
            case .failure(let error):
                self?.isLoadingMoreLocation = false
                print(error)
            }
        }
    }
    
    func registerDidFinishPaginationBlock(_ block: @escaping () -> Void) {
        self.didFinishPaginationBlock = block
    }
}
