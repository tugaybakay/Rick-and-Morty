//
//  RMCharacterDetailsViewViewModel.swift
//  RickAndMortyRA
//
//  Created by MacOS on 6.10.2023.
//

import UIKit

final class RMCharacterDetailsViewViewModel {
    
    enum SectionType {
        case photo(viewModel: RMCharacterPhotoCollectionViewCellViewModel)
        case information(viewModels: [RMCharacterInfoCollectionViewCellViewModel])
        case episodes(viewModel: [RMCharacterEpisodeCollectionViewCellViewModel])

    }
    var sections: [SectionType] = []
    
    var episodes: [String] {
        return character.episode
    }
    
    private let character: RMCharacter
    private var requestUrl: URL? {
        return URL(string: character.url)
    }
    init(_ character: RMCharacter) {
        self.character = character
        sections = [.photo(viewModel: .init(imageUrl: URL(string: character.image))),
                    .information(viewModels:
                                    [.init(value: character.status.rawValue, type: .status),
                                     .init(value: character.gender.rawValue, type: .gender),
                                     .init(value: character.type, type: .type),
                                     .init(value: character.species, type: .species),
                                     .init(value: character.created, type: .created),
                                     .init(value: character.location.name,type: .location),
                                     .init(value: character.origin.name, type: .origin),
                                     .init(value: character.episode.count.description, type: .episodeCount)]),
                    .episodes(viewModel: character.episode.compactMap({
                        return RMCharacterEpisodeCollectionViewCellViewModel(episodeUrl: URL(string: $0))
                    }))]
    }
    
    var title: String {
        return character.name.uppercased()
    }
    
//    func fetchCharacterData() {
//        guard let url = requestUrl,let request = RMRequest(url: url) else {return}
//        RMService.shared.execute(request, expecting: RMCharacter.self) { result in
//            switch result {
//            case .success(let data):
//                print(data)
//            case .failure(let error):
//                print(error)
//            }
//        }
//    }
    
    func createPhotoSectionLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0)
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.5)) , subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
   
    
    func createInformationSectionLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(UIDevice.isIphone ? 0.5 : 0.25), heightDimension: .fractionalHeight(1.0)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(150.0)) , subitems: UIDevice.isIphone ? [item,item] : [item,item,item,item])
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    
    
    func createEpisodeSectionLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 5, bottom: 15, trailing: 8)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(UIDevice.isIphone ? 0.8 : 0.4), heightDimension: .absolute(150)) , subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        return section
    }
}
