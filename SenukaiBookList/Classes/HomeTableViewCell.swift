//
//  OverviewTableViewCell.swift
//  SenukaiBookList
//
//  Created by Darius Jankauskas on 28/08/2022.
//  Copyright © 2022 Darius Jankauskas. All rights reserved.
//

import UIKit
import SnapKit

class HomeTableViewCell: UITableViewCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }

    var viewModel: BookList = BookList(list: List(id: 0, title: ""), books: []) {
        didSet {
            titleLabel.text = viewModel.list.title
            collectionView.reloadData()
        }
    }
    
    // MARK: Views

    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [topStackView, collectionView])
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()

    private lazy var topStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, button])
        stackView.axis = .horizontal
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        return label
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.allButton, for: .normal)
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        let spacing: CGFloat = 10
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = spacing
        layout.itemSize = collectionItemSize
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(BookCollectionViewCell.self, forCellWithReuseIdentifier: BookCollectionViewCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
        return collectionView
    }()
    
    private var collectionItemSize: CGSize {
        let width = UIScreen.main.bounds.width / 2.5
        return CGSize(width: width, height: width * 1.5 + 50)
    }

    // MARK: Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Collection View Data Source

extension HomeTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookCollectionViewCell.reuseIdentifier, for: indexPath) as! BookCollectionViewCell
        
        cell.viewModel = viewModel.books[indexPath.row]
        
        return cell
    }
}

// MARK: - Layout

extension HomeTableViewCell {
    private func layout() {
        contentView.addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        collectionView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(collectionItemSize)
        }
    }
}
