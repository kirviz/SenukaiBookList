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
    
//    private var overviewViewModels = [OverviewViewModel(), OverviewViewModel()]
    
    private let viewModel = HomeViewModel()
    
    private var bookLists: [BookList] = []
    
    private let disposeBag = DisposeBag()
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Strings.homeScreenTitle
        layout()
        viewModel.fetchBooksOverviewState()
        viewModel.stateObservable
            .bind { [weak self] state in
                self?.render(state: state)
            }.disposed(by: disposeBag)
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
            bookLists = []
        case .error(_):
            activityIndicator.stopAnimating()
        case .loaded(let bookLists):
            activityIndicator.stopAnimating()
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
        
        activityIndicator.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
