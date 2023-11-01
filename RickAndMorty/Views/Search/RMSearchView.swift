//
//  RMSearchView.swift
//  RickAndMortyRA
//
//  Created by MacOS on 24.10.2023.
//

import UIKit

protocol RMSearchViewDelegate: AnyObject {
    func rmSearchView(_ searchview: RMSearchView, didSelectOption option: DynamicOption)
    func rmSearchView(_ searchview: RMSearchView, didSelectLocation location: RMLocation)
    func rmSearchView(_ searchview: RMSearchView, didSelectCharacter character: RMCharacter)
    func rmSearchView(_ searchview: RMSearchView, didSelectEpisode episode: RMEpisode)
}

final class RMSearchView: UIView {

    weak var delegate: RMSearchViewDelegate?
    private let viewModel: RMSearchViewViewModel
    
    private let noResultView = RMNoSearchResultView()
    private let searchInputView = RMSearchInputView()
    private let resultView = RMSearchResultView()
    
    init(frame: CGRect, viewModel: RMSearchViewViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        addSubviews(resultView,noResultView,searchInputView)
        setUpConstraints()
        searchInputView.configure(with: .init(type: viewModel.config.type))
        searchInputView.delegate = self
        resultView.delegate = self
        setUpHandlers()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpHandlers() {
        viewModel.registerOptionChangeBlock { tuple in
            self.searchInputView.update(option: tuple.0, value: tuple.1)
        }
        
        viewModel.registerSearchResultHandler { [weak self] results in
            DispatchQueue.main.async {
                self?.resultView.configure(with: results)
                self?.noResultView.isHidden = true
                self?.resultView.isHidden = false
            }
        }
        
        viewModel.registerNoResultsHandler { [weak self] in
            DispatchQueue.main.async {
                self?.noResultView.isHidden = false
                self?.resultView.isHidden = true
            }
        }
    }
    
    private func setUpConstraints() {
        
        print(viewModel.config.type)
        NSLayoutConstraint.activate([
            // Search Input
            searchInputView.rightAnchor.constraint(equalTo: rightAnchor),
            searchInputView.leftAnchor.constraint(equalTo: leftAnchor),
            searchInputView.topAnchor.constraint(equalTo: topAnchor),
            searchInputView.heightAnchor.constraint(equalToConstant: viewModel.config.type == .episode ? 57 : 110),
            
            // Result View
            resultView.topAnchor.constraint(equalTo: searchInputView.bottomAnchor),
            resultView.leftAnchor.constraint(equalTo: leftAnchor),
            resultView.rightAnchor.constraint(equalTo: rightAnchor),
            resultView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // No Result
            noResultView.widthAnchor.constraint(equalToConstant: 150),
            noResultView.heightAnchor.constraint(equalToConstant: 150),
            noResultView.centerXAnchor.constraint(equalTo: centerXAnchor),
            noResultView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func presentKeyboard() {
        searchInputView.presentKeyboard()
    }
}

//MARK: - Collection View Delegate and DataSource
extension RMSearchView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}


//MARK: - RMSearchInputViewDelegate
extension RMSearchView: RMSearchInputViewDelegate {
    func rmSearhcView(_ inputView: RMSearchInputView, DidSelectOption option: DynamicOption) {
        delegate?.rmSearchView(self, didSelectOption: option)
    }
    
    func rmSearhcView(_ inputView: RMSearchInputView, didChangeSearchText text: String) {
        if text.isEmpty {
            noResultView.isHidden = true
            resultView.isHidden = true
            viewModel.set(query: "")
        }else {
            viewModel.set(query: text)
        }
    }
    
    func rmSearhcViewDidTapKeyboardSearchButton(_ inputView: RMSearchInputView) {
        viewModel.executeSearch()
    }
}

//MARK: - RMSearchResultViewDelegate Methods

extension RMSearchView: RMSearchResultViewDelegate {
    func rmSearchResultView(_ resultView: RMSearchResultView, didTapLocationAt index: Int) {
        guard let location = viewModel.locationSearchResult(at: index) else {return}
        delegate?.rmSearchView(self, didSelectLocation: location)
    }
    
    func rmSearchResultView(_ resultView: RMSearchResultView, didTapCharacterAt index: Int) {
        guard let character = viewModel.characterSearchResult(at: index) else {return}
        delegate?.rmSearchView(self, didSelectCharacter: character)
    }
    
    func rmSearchResultView(_ resultView: RMSearchResultView, didTapEpisodeAt index: Int) {
        guard let episode = viewModel.episodeSearchResult(at: index) else {return}
        delegate?.rmSearchView(self, didSelectEpisode: episode)
    }
}
