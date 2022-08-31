//
//  HomeViewController.swift
//  SenukaiBookList
//
//  Created by Darius Jankauskas on 28/08/2022.
//  Copyright © 2022 Darius Jankauskas. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {
    
    private let viewModel: HomeViewModel
    private var bookLists: [BookList] = []

    private let disposeBag = DisposeBag()
    
    init(homeViewModel: HomeViewModel) {
        self.viewModel = homeViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Views
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(frame: .zero)
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle =  NSAttributedString(string: Strings.pullToRefresh)
        refreshControl.addTarget(self, action: #selector(self.pullDown), for: .valueChanged)
        return refreshControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Strings.homeScreenTitle
        layout()
        viewModel.fetchBooksAndLists()
        viewModel.stateObservable
            .bind { [weak self] state in
                self?.render(state: state)
            }.disposed(by: disposeBag)
    }
}

// MARK: - Refresh

extension HomeViewController {
    @objc func pullDown() {
        // a crazy way to make the refresh happen on release
        perform(#selector(self.refresh), with: nil, afterDelay: 0, inModes: [.default])
    }
    
    @objc func refresh() {
        if refreshControl.isRefreshing {
            DispatchQueue.main.async { [weak self] in
                self?.refreshControl.endRefreshing()
                self?.viewModel.fetchBooksAndLists()
            }
        }
    }
}

// MARK: - Render

extension HomeViewController {
    func render(state: HomeViewModel.State) {
        switch state {
        case .idle:
            break
        case .loading:
            activityIndicator.startAnimating()
            errorLabel.isHidden = true
            bookLists = []
            tableView.reloadData()
        case .error(let error):
            activityIndicator.stopAnimating()
            errorLabel.isHidden = false
            errorLabel.text = Strings.errorMessage + "\(error)"
        case .loaded(let bookLists):
            activityIndicator.stopAnimating()
            errorLabel.isHidden = true
            self.bookLists = bookLists
            self.tableView.reloadData()
        }
    }
}

// MARK: - Table View Data Source

extension HomeViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        bookLists.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.reuseIdentifier, for: indexPath) as! HomeTableViewCell
        
        cell.viewModel = bookLists[indexPath.row]
        
        return cell
    }
}

// MARK: - Table View Delegate

extension HomeViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        
    }
}

// MARK: - Layout

extension HomeViewController {
    private func layout() {
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(errorLabel)
        tableView.refreshControl = refreshControl
        
        activityIndicator.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        errorLabel.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
    }
}
