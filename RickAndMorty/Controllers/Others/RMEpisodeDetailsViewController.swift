//
//  RMCharacterVC.swift
//  RickAndMortyRA
//
//  Created by MacOS on 3.10.2023.
//

import UIKit

class RMEpisodeDetailsViewController: UIViewController {
    
    private let detailsView = RMEpisodeDetailView()
    private let viewModel: RMEpisodeDetailViewViewModel
    
    private let url: URL?
    
    init(url: URL?) {
        self.url = url
        viewModel = RMEpisodeDetailViewViewModel(url: url)
        super.init(nibName: nil, bundle: nil)
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            detailsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            detailsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            detailsView.leftAnchor.constraint(equalTo: view.leftAnchor),
            detailsView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        detailsView.delegate = self
        view.addSubview(detailsView)
        viewModel.delegate = self
        viewModel.fetchEpisodeData()
        setUpConstraints()
        title = "Episode"
        addSearchButton()
    }
        
    private func addSearchButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(didTapShare))
    }
    
    @objc private func didTapShare() {
        
    }
}
 
extension RMEpisodeDetailsViewController: RMEpisodeDetailViewViewModelDelegate {
    func didFetchEpisodeDetails() {
        detailsView.configure(with: viewModel)
    }
}

extension RMEpisodeDetailsViewController: RMEpisodeDetailViewDelegate {
    func rmEpisodeDetailView(_ detailView: RMEpisodeDetailView, didSelectCharacter: RMCharacter) {
        let vc = RMCharacterDetailsViewController(viewModel: .init(didSelectCharacter))
        navigationController?.pushViewController(vc, animated: true)
    }
}
