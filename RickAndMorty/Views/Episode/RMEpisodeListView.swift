//
//  RMCharacterListView.swift
//  RickAndMortyRA
//
//  Created by MacOS on 6.10.2023.
//

import UIKit

protocol RMEpisodeListViewDelegate: AnyObject {
    func rmEpisodeListView(_ characterListView: RMEpisodeListView, didSelectEpisode: RMEpisode)
}

class RMEpisodeListView: UIView {
    
    weak var delegate: RMEpisodeListViewDelegate?
    
    private let viewModel = RMEpisodeListViewViewModel()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isHidden = true
        cv.alpha = 0
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(RMCharacterEpisodeCollectionViewCell.self, forCellWithReuseIdentifier: RMCharacterEpisodeCollectionViewCell.identifier)
        cv.register(RMFooterLoadingCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: RMFooterLoadingCollectionReusableView.identifier)
        return cv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        addSubviews(collectionView, spinner)
        addConstraintToViews()
        spinner.startAnimating()
        setUpCollectionView()
        viewModel.delegate = self
        viewModel.fetchEpisodes()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addConstraintToViews() {
        NSLayoutConstraint.activate([
            spinner.widthAnchor.constraint(equalToConstant: 100),
            spinner.heightAnchor.constraint(equalToConstant: 100),
            spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
        
    }
    
    private func setUpCollectionView() {
        collectionView.delegate = viewModel
        collectionView.dataSource = viewModel
        
    }
    
}

extension RMEpisodeListView: RMEpisodeListViewViewModelDelegate {
    func didLoadIntialEpisodes() {
        spinner.stopAnimating()
        collectionView.isHidden = false
        collectionView.reloadData()
        UIView.animate(withDuration: 0.4) {
            self.collectionView.alpha = 1
        }
    }
    
    func didSelectedEpisode(_ episode: RMEpisode) {
        delegate?.rmEpisodeListView(self, didSelectEpisode: episode)
    }
    
    func didLoadMoreEpisodes(with indexPaths: [IndexPath]) {
        collectionView.performBatchUpdates({
            self.collectionView.insertItems(at: indexPaths)
        })
    }
    

//    func didLoadIntialCharacters() {
//        spinner.stopAnimating()
//        collectionView.isHidden = false
//        collectionView.reloadData()
//        UIView.animate(withDuration: 0.4) {
//            self.collectionView.alpha = 1
//        }
//    }
//
//    func didSelectedCharacter(_ character: RMCharacter) {
//        delegate?.rmCharacterListView(self, didSelectcharacter: character)
//    }
//
//    func didLoadMoreCharacters(with newIndexPath: [IndexPath]) {
//        collectionView.performBatchUpdates({
//            self.collectionView.insertItems(at: newIndexPath)
//        })
//    }
}
