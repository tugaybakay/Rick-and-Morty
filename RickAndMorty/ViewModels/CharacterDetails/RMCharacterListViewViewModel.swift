//
//  RMCharacterListViewViewModel.swift
//  RickAndMortyRA
//
//  Created by MacOS on 6.10.2023.
//

import UIKit

protocol RMCharacterListViewViewModelDelegate: AnyObject {
    func didLoadIntialCharacters()
    func didSelectedCharacter(_ character: RMCharacter)
    func didLoadMoreCharacters(with indexPaths: [IndexPath])
}

final class RMCharacterListViewViewModel: NSObject {
    
    weak var delegate: RMCharacterListViewViewModelDelegate?
    
    private var isLoadingMoreCharactesr = false
    
    private var characters: [RMCharacter] = [] {
        didSet {
            for character in characters {
                let vm = RMCharacterCollectionViewCellViewModel(name: character.name, status: character.status, imageUrl: URL(string: character.image))
                if !cellViewModels.contains(vm) {
                    self.cellViewModels.append(vm)
                }
            }
        }
    }
    
    private var cellViewModels: [RMCharacterCollectionViewCellViewModel] = []
    
    func fetchCharacters() {
        RMService.shared.execute(RMRequest(endpoint: .character), expecting: RMGetAllCharatcerResponse.self) { [weak self] result in
            switch result {
            case .success(let responseModel):
                self?.characters = responseModel.results
                let info = responseModel.info
                self?.apiInfo = info
                DispatchQueue.main.async {
                    self?.delegate?.didLoadIntialCharacters()
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
    
    func fetchAddtionalCharacters(with url: URL) {
        guard !isLoadingMoreCharactesr else { return }
        print("deneme")
        isLoadingMoreCharactesr = true
        guard let request = RMRequest(url: url) else {
            isLoadingMoreCharactesr = false
            print("Failed to creat request")
            return
        }
//        print(url.absoluteString)
        RMService.shared.execute(request, expecting: RMGetAllCharatcerResponse.self) { [weak self] result in
            switch result {
            case .success(let responseModel):
                let moreResult = responseModel.results
                let info = responseModel.info
                self?.apiInfo = info
                
                let originalCount = self?.characters.count
                let newCount = moreResult.count
                let total = (originalCount ?? 0) + newCount
                let startingIndex = total - newCount
                
                let indexPathToAdd: [IndexPath] = Array(startingIndex..<(startingIndex + newCount)).compactMap({
                    return IndexPath(row: $0, section: 0)
                })
                print(indexPathToAdd.count)
                self?.characters.append(contentsOf: moreResult)
                DispatchQueue.main.async {
                    self?.delegate?.didLoadMoreCharacters(with: indexPathToAdd)
                    self?.isLoadingMoreCharactesr = false
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension RMCharacterListViewViewModel: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RMCharacterCollectionViewCell.cellIdentifier, for: indexPath) as! RMCharacterCollectionViewCell
        let viewModel = cellViewModels[indexPath.row]
        cell.configure(with: viewModel)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let isIphone = UIDevice.current.userInterfaceIdiom == .phone
        let width: CGFloat
        if isIphone {
            width = (collectionView.bounds.width - 30)/2
        }else {
            // mac and ipad
            width = (collectionView.bounds.width - 50)/4
        }
        return CGSizeMake(width, width * 1.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let character = characters[indexPath.row]
        delegate?.didSelectedCharacter(character)
    }
}

extension RMCharacterListViewViewModel: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard shouldShowLoadMoreIndicator, !isLoadingMoreCharactesr,!cellViewModels.isEmpty,let urlString = apiInfo?.next,let url = URL(string: urlString)  else {return}
        
        Timer.scheduledTimer(withTimeInterval: 0.06, repeats: false) { [weak self] t in
            let offset = scrollView.contentOffset.y
            let totalContentHeight = scrollView.contentSize.height
            let totalScrollViewFixedHeight = scrollView.frame.size.height
            if offset >= (totalContentHeight - totalScrollViewFixedHeight - 120) {
                self?.fetchAddtionalCharacters(with: url)
            }
            t.invalidate()
        }
        
    }
}
