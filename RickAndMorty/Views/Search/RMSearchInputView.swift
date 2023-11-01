//
//  RMSearchInputView.swift
//  RickAndMortyRA
//
//  Created by MacOS on 24.10.2023.
//

import UIKit

protocol RMSearchInputViewDelegate: AnyObject {
    func rmSearhcView(_ inputView: RMSearchInputView, DidSelectOption option: DynamicOption)
    func rmSearhcView(_ inputView: RMSearchInputView, didChangeSearchText text: String)
    func rmSearhcViewDidTapKeyboardSearchButton(_ inputView: RMSearchInputView)
}

final class RMSearchInputView: UIView {
    
    weak var delegate: RMSearchInputViewDelegate?
    
    private var stackView: UIStackView?
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private var viewModel: RMSearchInputViewViewModel? {
        didSet{
            guard let viewModel = viewModel, viewModel.hasDynamicOptions else {return}
            let options = viewModel.options
            createOptionSelectionViews(options: options)
        }
        
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
//        backgroundColor = .red
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews(searchBar)
        setUpConstraints()
        self.searchBar.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("unSupported")
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            searchBar.leftAnchor.constraint(equalTo: leftAnchor),
            searchBar.rightAnchor.constraint(equalTo: rightAnchor),
            searchBar.topAnchor.constraint(equalTo: topAnchor,constant: -2),
            searchBar.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func createStackViewOption() -> UIStackView {
        let stackView = UIStackView()
        self.stackView = stackView
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 6
        addSubview(stackView)
        return stackView
    }
    
    private func createOptionSelectionViews(options: [DynamicOption]) {
        let stackView = createStackViewOption()

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            stackView.leftAnchor.constraint(equalTo: leftAnchor),
            stackView.rightAnchor.constraint(equalTo: rightAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        for x in 0..<options.count {
            let option = options[x]
            let button = UIButton()
            button.setAttributedTitle(NSAttributedString(string: option.rawValue,attributes: [
                .font: UIFont.systemFont(ofSize: 18, weight: .medium),
                .foregroundColor: UIColor.label,
                
            ]), for: .normal)
//            button.setTitle(nil, for: .normal)
            button.backgroundColor = .secondarySystemFill
//            button.setTitleColor(.label, for: .normal)
            button.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
            button.tag = x
            button.layer.cornerRadius = 6
            stackView.addArrangedSubview(button)
        }
    }
    
    @objc private func didTapButton(_ sender: UIButton) {
        guard let options = viewModel?.options else {return}
        let tag = sender.tag
        let selected = options[tag]
        delegate?.rmSearhcView(self, DidSelectOption: selected)
        
    }
    
    func presentKeyboard() {
        searchBar.becomeFirstResponder()
    }
    
    func update(option: DynamicOption, value: String) {
        guard let buttons = stackView?.arrangedSubviews as? [UIButton],
        let allOptions = viewModel?.options,
        let index = allOptions.firstIndex(of: option) else {return}
        
        let button: UIButton = buttons[index]
        button.setAttributedTitle(NSAttributedString(string: value.uppercased(),attributes: [
            .font: UIFont.systemFont(ofSize: 18, weight: .medium),
            .foregroundColor: UIColor.link,
            
        ]), for: .normal)
       
    }
    
    func configure(with viewModel: RMSearchInputViewViewModel) {
        searchBar.placeholder = viewModel.searchPlaceHolderText
        self.viewModel = viewModel
    }
}

extension RMSearchInputView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.rmSearhcView(self, didChangeSearchText: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        delegate?.rmSearhcViewDidTapKeyboardSearchButton(self)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("adadadadadad")
    }
}
