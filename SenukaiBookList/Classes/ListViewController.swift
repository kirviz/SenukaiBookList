//
//  ListViewController.swift
//  SenukaiBookList
//
//  Created by Darius Jankauskas on 31/08/2022.
//  Copyright © 2022 Darius Jankauskas. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

class ListViewController: UIViewController {

    private let viewModel: HomeViewModel
    private var bookList: BookList
    private let apiClient = ApiClient()

    private let disposeBag = DisposeBag()
    
    init(viewModel: HomeViewModel,
         bookList: BookList) {
        self.viewModel = viewModel
        self.bookList = bookList
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
        tableView.register(ListTableViewCell.self, forCellReuseIdentifier: ListTableViewCell.reuseIdentifier)
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
        
        title = bookList.list.title
        layout()
        tableView.reloadData()
        
        viewModel.stateObservable
            .bind { [weak self] state in
                self?.render(state: state)
            }.disposed(by: disposeBag)
    }
}

// MARK: - Refresh

extension ListViewController {
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

extension ListViewController {
    func render(state: HomeViewModel.State) {
        switch state {
        case .idle:
            break
        case .loading:
            activityIndicator.startAnimating()
            errorLabel.isHidden = true
            bookList = BookList(list: bookList.list, books: [])
            tableView.reloadData()
        case .error(let error):
            activityIndicator.stopAnimating()
            errorLabel.isHidden = false
            errorLabel.text = Strings.errorMessage + "\(error)"
        case .loaded(let bookLists):
            activityIndicator.stopAnimating()
            errorLabel.isHidden = true
            // TODO: fix this (make a dictionary or just run through the list or something)
            self.bookList = bookLists[bookList.list.id - 1]
            self.tableView.reloadData()
        }
    }
}

// MARK: - Table View Data Source

extension ListViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        bookList.books.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListTableViewCell.reuseIdentifier, for: indexPath) as! ListTableViewCell
        cell.book = bookList.books[indexPath.row]
        // TODO: change to using the viewModel
        apiClient.makeRequest(endpoint: .book(cell.book.id))
            .observe(on: MainScheduler.instance)
            .subscribe { (book: Book) in
                cell.book = book
                cell.setNeedsLayout()
            }.disposed(by: disposeBag)

        return cell
    }
}

// MARK: - Table View Delegate

extension ListViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let book = bookList.books[indexPath.row]
        Navigator.shared.showDetails(book: book)
    }
}

// MARK: - Layout

extension ListViewController {
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
