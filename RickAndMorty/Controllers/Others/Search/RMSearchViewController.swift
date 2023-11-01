//
//  RMSearchViewController.swift
//  RickAndMortyRA
//
//  Created by MacOS on 16.10.2023.
//

import UIKit

class RMSearchViewController: UIViewController {

    struct Config {
        enum ConfigType {
            case character
            case episode
            case location
            
            var searchResponseType: Any.Type {
                switch self {
                case .character: return RMGetAllCharatcerResponse.self
                case .episode: return RMGetAllEpisodesResponse.self
                case .location: return RMGetLocationResponse.self
                }
            }
            
            var endpoint: RMEndpoint {
                switch self{
                case .character:
                    return .character
                case .episode:
                    return .episode
                case .location:
                    return .location
                }
            }
            
            var title: String {
                switch self{
                case .character:
                    return "Search Character"
                case .location:
                    return "Search Location"
                case .episode:
                    return "Search Episode"
                }
            }
        }
    
        let type: ConfigType
    }
    
    private let config: Config
    
    private let searchView: RMSearchView
    
    private var viewModel: RMSearchViewViewModel
    
    init(config: Config) {
        self.config = config
        let viewModel = RMSearchViewViewModel(config: config)
        self.viewModel = viewModel
        self.searchView = RMSearchView(frame: .zero, viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = config.type.title
        view.backgroundColor = .systemBackground
        view.addSubview(searchView)
        setUpConstraints()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Search", style: .done, target: self, action: #selector(didTapExecuteSearch))
        searchView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchView.presentKeyboard()
    }
    
    @objc private func didTapExecuteSearch() {
        viewModel.executeSearch()
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            searchView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchView.leftAnchor.constraint(equalTo: view.leftAnchor),
            searchView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            searchView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }

}

extension RMSearchViewController: RMSearchViewDelegate {
    
    func rmSearchView(_ searchview: RMSearchView, didSelectCharacter character: RMCharacter) {
        let viewModel = RMCharacterDetailsViewViewModel(character)
        let vc = RMCharacterDetailsViewController(viewModel: viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func rmSearchView(_ searchview: RMSearchView, didSelectEpisode episode: RMEpisode) {
        let vc = RMEpisodeDetailsViewController(url: URL(string: episode.url))
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func rmSearchView(_ searchview: RMSearchView, didSelectOption option: DynamicOption) {
        let vc = RMSearchOptionPickerViewController(option: option) { [weak self] selection in
            self?.viewModel.set(value: selection, for: option)
        }
        vc.sheetPresentationController?.detents = [.medium()]
        vc.sheetPresentationController?.prefersGrabberVisible = true
        present(vc, animated: true)
    }
    
    func rmSearchView(_ searchview: RMSearchView, didSelectLocation location: RMLocation) {
        let vc = RMLocationDetailViewController(location: location)
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}
