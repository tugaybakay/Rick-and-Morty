//
//  RMSearchResultView.swift
//  RickAndMortyRA
//
//  Created by MacOS on 26.10.2023.
//

import UIKit

protocol RMSearchResultViewDelegate: AnyObject {
    func rmSearchResultView(_ resultView: RMSearchResultView, didTapLocationAt index: Int)
    func rmSearchResultView(_ resultView: RMSearchResultView, didTapCharacterAt index: Int)
    func rmSearchResultView(_ resultView: RMSearchResultView, didTapEpisodeAt index: Int)
}

class RMSearchResultView: UIView {
    
    private var viewModel: RMSearchResultViewModel? {
        didSet {
            processViewModel()
        }
    }
    
    weak var delegate: RMSearchResultViewDelegate?
    
    var locationCellViewModels: [RMLocationTableViewCellViewModel] = []
    
    var collectionViewCellViewModels: [any Hashable] = []
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.isHidden = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(RMLocationTableViewCell.self, forCellReuseIdentifier: RMLocationTableViewCell.cellIdentifier)
        
        return tableView
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isHidden = true
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(RMCharacterCollectionViewCell.self, forCellWithReuseIdentifier: RMCharacterCollectionViewCell.cellIdentifier)
        cv.register(RMCharacterEpisodeCollectionViewCell.self, forCellWithReuseIdentifier: RMCharacterEpisodeCollectionViewCell.identifier)
        cv.register(RMFooterLoadingCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: RMFooterLoadingCollectionReusableView.identifier)
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isHidden = true
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        addSubviews(tableView,collectionView)
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("unSupported!")
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leftAnchor.constraint(equalTo: leftAnchor),
            tableView.rightAnchor.constraint(equalTo: rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            collectionView.topAnchor.constraint(equalTo: topAnchor,constant: 10),
            collectionView.leftAnchor.constraint(equalTo: leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func processViewModel() {
        guard let viewModel = viewModel else {return}
        
        switch viewModel.result {
        case .characters(let viewModels):
            self.collectionViewCellViewModels = viewModels
            setUpCollectionView()
            break
        case .episodes(let viewModels):
            self.collectionViewCellViewModels = viewModels
            setUpCollectionView()
        case .locations(let viewModels):
            setUpTableView(with: viewModels)
        }
    }
    
    private func setUpCollectionView() {
        tableView.isHidden = true
        collectionView.isHidden = false
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.reloadData()
    }
    
    private func setUpTableView(with viewModels: [RMLocationTableViewCellViewModel]) {
        self.locationCellViewModels = viewModels
        tableView.isHidden = false
        collectionView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    func configure(with viewModel: RMSearchResultViewModel) {
        self.viewModel = viewModel
    }
    
    private func showTableLoadingIndicator() {
        let footer = RMTableLoadingFooterView()
        footer.frame = CGRect(x: 0, y: -20, width: UIScreen.main.bounds.width, height: 100)
        tableView.tableFooterView = footer
    }

}

//MARK: - Table View Delegate and DataSource
//
extension RMSearchResultView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationCellViewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RMLocationTableViewCell.cellIdentifier, for: indexPath) as! RMLocationTableViewCell
        cell.configure(with: locationCellViewModels[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.rmSearchResultView(self, didTapLocationAt: indexPath.row)
    }
}

//MARK: - Collection View Delegate and DataSource
extension RMSearchResultView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewCellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let viewModel = collectionViewCellViewModels[indexPath.row]
        if viewModel is RMCharacterCollectionViewCellViewModel {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RMCharacterCollectionViewCell.cellIdentifier, for: indexPath) as? RMCharacterCollectionViewCell else { fatalError() }
            if let characterVM = viewModel as? RMCharacterCollectionViewCellViewModel {
                cell.configure(with: characterVM)
            }
            return cell
        }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RMCharacterEpisodeCollectionViewCell.identifier, for: indexPath) as? RMCharacterEpisodeCollectionViewCell else { fatalError() }
        if let episodeVM = viewModel as? RMCharacterEpisodeCollectionViewCellViewModel {
            cell.configure(with: episodeVM)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let viewModel = viewModel else {return}
        
        switch viewModel.result {
        case .characters:
            delegate?.rmSearchResultView(self, didTapCharacterAt: indexPath.row)
        case .episodes:
            delegate?.rmSearchResultView(self, didTapEpisodeAt: indexPath.row)
        case .locations:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let currentViewModel = collectionViewCellViewModels[indexPath.row]
        let bounds = collectionView.bounds
        if currentViewModel is RMCharacterCollectionViewCellViewModel {
            let width = UIDevice.isIphone ? (bounds.width - 30) / 2 : (bounds.width - 50) / 4
            return CGSizeMake( width, width * 1.5)
        }
        let width = UIDevice.isIphone ? (bounds.width - 20) : (bounds.width - 40) / 2
        
        return CGSizeMake(width, UIDevice.isIphone ? width / 3 : width / 2.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionFooter,let viewModel = viewModel, viewModel.shouldShowLoadMoreIndicator else {
            return UICollectionReusableView()
        }
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: RMFooterLoadingCollectionReusableView.identifier, for: indexPath)
        return footer
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard let viewModel = viewModel, viewModel.shouldShowLoadMoreIndicator else {return .zero}
        return CGSizeMake(collectionView.frame.width, 100)
    }
}

//MARK: - Scroll View Delegate
extension RMSearchResultView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !locationCellViewModels.isEmpty {
            handleLocationPagination(scrollView: scrollView)
        }else{
            // Collection View Pagination
            handleCharacterOrEpisodePagination(scrollView: scrollView)
        }
    }
    
    private func handleLocationPagination(scrollView: UIScrollView) {
        guard let viewModel = viewModel, !locationCellViewModels.isEmpty, viewModel.shouldShowLoadMoreIndicator, !viewModel.isLoadingMoreResults else {
            return
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] t in
            let offset = scrollView.contentOffset.y
            let totalContentHeight = scrollView.contentSize.height
            let totalScrollViewFixedHeight = scrollView.frame.size.height
            if offset >= (totalContentHeight - totalScrollViewFixedHeight - 120) {
                DispatchQueue.main.async {
                    self?.showTableLoadingIndicator()
                }
                viewModel.fetchAddtionalLocations { [weak self] locationCellViewModels in
                    self?.tableView.tableFooterView = nil
                    self?.locationCellViewModels = locationCellViewModels
                    self?.tableView.reloadData()
                    
                    
                }
            }
            t.invalidate()
        }
    }
    
    private func handleCharacterOrEpisodePagination(scrollView: UIScrollView) {
        guard let viewModel = viewModel, !collectionViewCellViewModels.isEmpty, viewModel.shouldShowLoadMoreIndicator, !viewModel.isLoadingMoreResults else {
            return
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] t in
            let offset = scrollView.contentOffset.y
            let totalContentHeight = scrollView.contentSize.height
            let totalScrollViewFixedHeight = scrollView.frame.size.height
            if offset >= (totalContentHeight - totalScrollViewFixedHeight - 120) {
                viewModel.fetchAddtionalResults { [weak self] results in
                    DispatchQueue.main.async {
                        let originalCount = self?.collectionViewCellViewModels.count ?? 0
                        let newCount = results.count - originalCount
                        let totalCount = originalCount + newCount
                        let startingIndex = totalCount - newCount
                        let indexPathToAdd: [IndexPath] = Array(startingIndex..<totalCount).compactMap({
                            return IndexPath(row: $0, section: 0)
                        })
                        self?.collectionViewCellViewModels = results
                        self?.collectionView.performBatchUpdates({
                            self?.collectionView.insertItems(at: indexPathToAdd)
                        })
                    }
                }
            }
            t.invalidate()
        }
    }
    
}
