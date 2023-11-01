//
//  RMCharacterVC.swift
//  RickAndMortyRA
//
//  Created by MacOS on 3.10.2023.
//

import UIKit

class RMEpisodeViewController: UIViewController {
    
    private let episodeListView = RMEpisodeListView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Episode"
        view.backgroundColor = .systemBackground
        view.addSubview(episodeListView)
        addConstraintsToViews()
        episodeListView.delegate = self
        addSearchButton()
        //        let request = RMRequest(endpoint: .character)
        //        print(request.url)
    }
    
    private func addConstraintsToViews() {
        NSLayoutConstraint.activate([
            episodeListView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            episodeListView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            episodeListView.leftAnchor.constraint(equalTo: view.leftAnchor),
            episodeListView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    private func addSearchButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(didTapShare))
    }
    
    @objc private func didTapShare() {
        let vc = RMSearchViewController(config: .init(type: .episode))
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension RMEpisodeViewController: RMEpisodeListViewDelegate {
    func rmEpisodeListView(_ characterListView: RMEpisodeListView, didSelectEpisode: RMEpisode) {
        let detailsVC = RMEpisodeDetailsViewController(url: URL(string: didSelectEpisode.url) )
        detailsVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(detailsVC, animated: true)
    }
    
}
