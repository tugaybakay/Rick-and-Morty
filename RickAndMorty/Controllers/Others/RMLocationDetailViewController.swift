//
//  RMLocationDetailViewController.swift
//  RickAndMortyRA
//
//  Created by MacOS on 24.10.2023.
//

import UIKit

final class RMLocationDetailViewController: UIViewController {

    private let detailsView = RMLocationDetailView()
    private let viewModel: RMLocationDetailViewViewModel
    
    private let url: URL?
    
    init(location: RMLocation) {
        self.url = URL(string: location.url)
        viewModel = RMLocationDetailViewViewModel(url: url)
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
        viewModel.fetchLocationData()
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
 
extension RMLocationDetailViewController: RMLocationDetailViewViewModelDelegate {
    func didFetchLocationDetails() {
        detailsView.configure(with: viewModel)
    }
}

extension RMLocationDetailViewController: RMLocationDetailViewDelegate {
    func rmLocationDetailView(_ detailView: RMLocationDetailView, didSelect character: RMCharacter) {
        let vc = RMCharacterDetailsViewController(viewModel: .init(character))
        navigationController?.pushViewController(vc, animated: true)
    }
}
