//
//  RMEpisodeListViewViewModel.swift
//  RickAndMortyRA
//
//  Created by MacOS on 6.10.2023.
//

import UIKit

protocol RMEpisodeListViewViewModelDelegate: AnyObject {
    func didLoadIntialEpisodes()
    func didSelectedEpisode(_ episode: RMEpisode)
    func didLoadMoreEpisodes(with indexPaths: [IndexPath])
}

final class RMEpisodeListViewViewModel: NSObject {
     
    weak var delegate: RMEpisodeListViewViewModelDelegate?
    
    private var isLoadingMoreEpisodes = false
    
    private var episodes: [RMEpisode] = [] {
        didSet {
            for episode in episodes {
                let vm = RMCharacterEpisodeCollectionViewCellViewModel(episodeUrl: URL(string: episode.url))
                if !cellViewModels.contains(vm) {
                    self.cellViewModels.append(vm)
                }
            }
        }
    }
    
    private var cellViewModels: [RMCharacterEpisodeCollectionViewCellViewModel] = []
    
    func fetchEpisodes() {
        RMService.shared.execute(RMRequest(endpoint: .episode), expecting: RMGetAllEpisodesResponse.self) { [weak self] result in
            switch result {
            case .success(let responseModel):
                self?.episodes = responseModel.results
                let info = responseModel.info
                self?.apiInfo = info
                DispatchQueue.main.async {
                    self?.delegate?.didLoadIntialEpisodes()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private var apiInfo: Info? = nil
    
    var shouldShowLoadMoreIndicator: Bool {
        return apiInfo?.next != nil
    }
    
    func fetchAddtionalEpisodes(with url: URL) {
        guard !isLoadingMoreEpisodes else { return }
        print("deneme")
        isLoadingMoreEpisodes = true
        guard let request = RMRequest(url: url) else {
            isLoadingMoreEpisodes = false
            print("Failed to creat request")
            return
        }
//        print(url.absoluteString)
        RMService.shared.execute(request, expecting: RMGetAllEpisodesResponse.self) { [weak self] result in
            switch result {
            case .success(let responseModel):
                let moreResult = responseModel.results
                let info = responseModel.info
                self?.apiInfo = info
                
                let originalCount = self?.episodes.count
                let newCount = moreResult.count
                let total = (originalCount ?? 0) + newCount
                let startingIndex = total - newCount
                
                let indexPathToAdd: [IndexPath] = Array(startingIndex..<(startingIndex + newCount)).compactMap({
                    return IndexPath(row: $0, section: 0)
                })
                print(indexPathToAdd.count)
                self?.episodes.append(contentsOf: moreResult)
                DispatchQueue.main.async {
                    self?.delegate?.didLoadMoreEpisodes(with: indexPathToAdd)
                    self?.isLoadingMoreEpisodes = false
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension RMEpisodeListViewViewModel: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionFooter, shouldShowLoadMoreIndicator else {
            return UICollectionReusableView()
        }
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: RMFooterLoadingCollectionReusableView.identifier, for: indexPath)
        return footer
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard shouldShowLoadMoreIndicator else {return .zero}
        return CGSizeMake(collectionView.frame.width, 100)
    }
 
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RMCharacterEpisodeCollectionViewCell.identifier, for: indexPath) as! RMCharacterEpisodeCollectionViewCell
        let viewModel = cellViewModels[indexPath.row]
        cell.configure(with: viewModel)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIDevice.isIphone ? (UIScreen.main.bounds.width - 20)  : (UIScreen.main.bounds.width - 40) / 2
        return CGSizeMake(width, UIDevice.isIphone ? (width / 3.2) : (width / 2.5))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let episode = episodes[indexPath.row]
        delegate?.didSelectedEpisode(episode)
    }
}

extension RMEpisodeListViewViewModel: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard shouldShowLoadMoreIndicator, !isLoadingMoreEpisodes,!cellViewModels.isEmpty,let urlString = apiInfo?.next,let url = URL(string: urlString)  else {return}
        
        Timer.scheduledTimer(withTimeInterval: 0.06, repeats: false) { [weak self] t in
            let offset = scrollView.contentOffset.y
            let totalContentHeight = scrollView.contentSize.height
            let totalScrollViewFixedHeight = scrollView.frame.size.height
            if offset >= (totalContentHeight - totalScrollViewFixedHeight - 120) {
                self?.fetchAddtionalEpisodes(with: url)
            }
            t.invalidate()
        }
        
    }
}
