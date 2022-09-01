//
//  ListTableViewCell.swift
//  SenukaiBookList
//
//  Created by Darius Jankauskas on 31/08/2022.
//  Copyright © 2022 Darius Jankauskas. All rights reserved.
//

import UIKit
import SnapKit

class ListTableViewCell: UITableViewCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    private var fetchTask: URLSessionTask? {
        willSet {
            fetchTask?.cancel()
        }
    }

    var book: Book = Book(id: 0, listId: 0, title: "", img: "") {
        didSet {
            fetchTask = thumbnailView.load(img: book.img, withTransitionView: thumbnailView)
            titleLabel.text = book.title
            authorLabel.text = book.author
        }
    }
    
    // MARK: Views

    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [thumbnailView, sideStackView])
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.spacing = 0
        stackView.layoutMargins = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 0)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private lazy var thumbnailView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 3
        return imageView
    }()

    private lazy var sideStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, authorLabel])
        stackView.axis = .vertical
        stackView.layoutMargins = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 6)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        return label
    }()
    
    private lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .gray
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        return label
    }()

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

// MARK: - Layout

extension ListTableViewCell {
    private func layout() {
        contentView.addSubview(mainStackView)

        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        thumbnailView.snp.makeConstraints { make in
            make.height.equalTo(110)
            make.width.equalTo(77)
        }
    }
}
