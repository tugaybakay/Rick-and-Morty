//
//  RMCharacterVC.swift
//  RickAndMortyRA
//
//  Created by MacOS on 3.10.2023.
//

import UIKit

class RMCharacterViewController: UIViewController {
    
    private let charaterListView = RMCharacterListView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Character"
        view.backgroundColor = .systemBackground
        view.addSubview(charaterListView)
        addConstraintsToViews()
        charaterListView.delegate = self
        addSearchButton()
        //        let request = RMRequest(endpoint: .character)
        //        print(request.url)
    }
    
    private func addSearchButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(didTapShare))
    }
    
    @objc private func didTapShare() {
        let vc = RMSearchViewController(config: RMSearchViewController.Config(type: .character))
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func addConstraintsToViews() {
        NSLayoutConstraint.activate([
            charaterListView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            charaterListView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            charaterListView.leftAnchor.constraint(equalTo: view.leftAnchor),
            charaterListView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
}

extension RMCharacterViewController: RMCharacterListViewDelegate {
    func rmCharacterListView(_ characterListView: RMCharacterListView, didSelectcharacter: RMCharacter) {
        let detailsVM = RMCharacterDetailsViewViewModel(didSelectcharacter)
        let detailsVC = RMCharacterDetailsViewController(viewModel: detailsVM)
        detailsVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(detailsVC, animated: true)
    }
    
}
