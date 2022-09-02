//
//  ListViewModel.swift
//  SenukaiBookList
//
//  Created by Darius Jankauskas on 02/09/2022.
//  Copyright © 2022 Darius Jankauskas. All rights reserved.
//

import Foundation
import RxSwift

class ListViewModel {
    enum BookListError: Error {
        case bookListNotFound
    }

    enum State {
        case idle
        case loading
        case error(Error)
        case loaded(BookList)
    }
    
    let homeViewModel: HomeViewModel
    let apiClient: ApiClient
    
    init(homeViewModel: HomeViewModel, apiClient: ApiClient = ApiClient()) {
        self.homeViewModel = homeViewModel
        self.apiClient = apiClient
    }
    
    func stateObservable(listId: Int) -> Observable<State> {
        return homeViewModel.stateObservable
            .map { state in
                State(state: state, listId: listId)
            }
    }
    
    func refresh() {
        homeViewModel.fetchBooksAndLists()
    }
    
    func loadBook(bookId: Int) -> Observable<Book> {
        return apiClient.makeRequest(endpoint: .book(bookId))
            .observe(on: MainScheduler.instance)
    }
}

extension ListViewModel.State {
    init(state: HomeViewModel.State, listId: Int) {
        switch state {
        case .idle:
            self = .idle
        case .loading:
            self = .loading
        case .error(let error):
            self = .error(error)
        case .loaded(let bookLists):
            let bookListOptional = bookLists.first { $0.list.id == listId }
            guard let bookList = bookListOptional else {
                self = .error(ListViewModel.BookListError.bookListNotFound)
                return
            }
            self = .loaded(bookList)
        }
    }
}
