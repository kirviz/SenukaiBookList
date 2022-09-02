//
//  DetailsViewController.swift
//  SenukaiBookList
//
//  Created by Darius Jankauskas on 30/08/2022.
//  Copyright © 2022 Darius Jankauskas. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class DetailsViewController: UIViewController {
    
    private let viewModel: DetailsViewModel
    private let disposeBag = DisposeBag()
    
    private var fetchTask: URLSessionTask? {
        willSet {
            fetchTask?.cancel()
        }
    }
    
    required init(viewModel: DetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Views
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, activityIndicator, errorLabel, innerStackView])
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var innerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, authorLabel, isbnStackView, dateStackView, descriptionLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 32, right: 10)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.setCustomSpacing(24, after: dateStackView)
        return stackView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.numberOfLines = 0
        return label
    }()

    private lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var isbnStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [isbnCaption, isbnLabel])
        stackView.axis = .horizontal
        stackView.spacing = 4
        return stackView
    }()

    private lazy var isbnCaption : UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.text = Strings.isbn
        return label
    }()
    
    private lazy var isbnLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var dateStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [dateCaption, dateLabel])
        stackView.axis = .horizontal
        stackView.spacing = 4
        return stackView
    }()

    private lazy var dateCaption : UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.text = Strings.publicationDateCaption
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .darkGray
        return label
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
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        layout()
        
        viewModel.stateObservable
            .bind { [weak self] state in
                self?.render(state: state)
            }.disposed(by: disposeBag)
        
        if viewModel.book.author == nil {
            viewModel.fetchBook(id: viewModel.book.id)
        }
    }
}

// MARK: - Render

extension DetailsViewController {
    private func render(state: DetailsViewModel.State) {
        switch state {
        case .loading:
            activityIndicator.startAnimating()
            innerStackView.isHidden = true
            errorLabel.text = nil
        case .error(let error):
            activityIndicator.stopAnimating()
            innerStackView.isHidden = true
            errorLabel.text = Strings.errorMessage + "\(error)"
        case .loaded(let book):
            activityIndicator.stopAnimating()
            innerStackView.isHidden = false
            errorLabel.text = nil
            
            fetchTask = imageView.load(img: book.img, withTransitionView: imageView)
            titleLabel.text = book.title
            authorLabel.text = book.author
            isbnLabel.text = book.isbn
            dateLabel.text = book.publicationFormattedAsIso
            descriptionLabel.text = book.description
        }
    }
}

// MARK: - Refresh

extension DetailsViewController {
    @objc func pullDown() {
        // a crazy way to make the refresh happen on release
        perform(#selector(self.refresh), with: nil, afterDelay: 0, inModes: [.default])
    }
    
    @objc func refresh() {
        if refreshControl.isRefreshing {
            DispatchQueue.main.async { [refreshControl, viewModel] in
                refreshControl.endRefreshing()
                viewModel.fetchBook(id: viewModel.book.id)
            }
        }
    }
}

// MARK: - Layout

extension DetailsViewController {
    private func layout() {
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        scrollView.refreshControl = refreshControl
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.height.equalTo(view).multipliedBy(0.5)
        }
    }
}
