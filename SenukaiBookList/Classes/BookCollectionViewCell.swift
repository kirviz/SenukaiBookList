//
//  BookCollectionViewCell.swift
//  SenukaiBookList
//
//  Created by Darius Jankauskas on 28/08/2022.
//  Copyright © 2022 Darius Jankauskas. All rights reserved.
//

import UIKit
import SnapKit

class BookCollectionViewCell: UICollectionViewCell {
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
            titleLabel.text = book.title
            fetchTask = imageView.load(img: book.img, withTransitionView: imageView)
        }
    }
    
    // MARK: - Views
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor(red: 245/255.0, green: 237/255.0, blue: 228/255.0, alpha: 1)
        return label
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
        contentView.backgroundColor = UIColor(red: 104/255.0, green: 17/255.0, blue: 39/255.0, alpha: 1)
        contentView.layer.cornerRadius = 3
        contentView.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Layout

extension BookCollectionViewCell {
    func layout() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        
        imageView.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
            make.width.equalTo(contentView.snp.width)
            make.height.equalTo(contentView.snp.width).multipliedBy(1.5)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(6)
            make.right.equalToSuperview().offset(-6)
            make.top.equalTo(imageView.snp.bottom)
            make.bottom.equalToSuperview()
        }
    }
}
