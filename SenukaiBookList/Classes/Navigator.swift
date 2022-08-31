//
//  Navigator.swift
//  SenukaiBookList
//
//  Created by Darius Jankauskas on 30/08/2022.
//  Copyright © 2022 Darius Jankauskas. All rights reserved.
//

import UIKit

class Navigator {
    static let shared = Navigator()
    
    private let homeViewModel = HomeViewModel()
    private let navigationController: UINavigationController
    
    private init() {
        navigationController = UINavigationController(rootViewController: HomeViewController(homeViewModel: homeViewModel))
    }
    
    var rootViewController: UIViewController {
        return navigationController
    }
    
    func showDetails(book: Book) {
        let detailsViewModel = DetailsViewModel(book: book)
        navigationController.pushViewController(DetailsViewController(viewModel: detailsViewModel), animated: true)
    }
}
