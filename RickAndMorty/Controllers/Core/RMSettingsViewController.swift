//
//  RMSettingsViewController.swift
//  RickAndMortyRA
//
//  Created by MacOS on 3.10.2023.
//

import SwiftUI
import UIKit
import SafariServices
import StoreKit

class RMSettingsViewController: UIViewController {
    
    private var settingsSwiftUIController: UIHostingController<RMSettingsView>?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        addSwiftUIController()
    }
    
    
    private func addSwiftUIController() {
        
        let settingsSwiftUIController = UIHostingController(rootView: RMSettingsView(viewModel: RMSettingsViewViewModel(cellViewModels: RMSettingsOption.allCases.compactMap({
            return RMSettingsCellViewModel(type: $0) { [weak self] option in
                self?.handleTap(option: option)
            }
        }))))
        
        addChild(settingsSwiftUIController)
        settingsSwiftUIController.didMove(toParent: self)
        view.addSubview(settingsSwiftUIController.view)
        settingsSwiftUIController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            settingsSwiftUIController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            settingsSwiftUIController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            settingsSwiftUIController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            settingsSwiftUIController.view.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        self.settingsSwiftUIController = settingsSwiftUIController
    }

    private func handleTap(option: RMSettingsOption) {
        guard Thread.current.isMainThread else { return }
        
        if let url = option.targetUrl {
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true)
        }else if option == .rateApp {
            if let windowScene = view.window?.windowScene {
                SKStoreReviewController.requestReview(in: windowScene)
            }
        }
    }
    
}
