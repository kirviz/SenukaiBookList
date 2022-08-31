//
//  HomeViewModel.swift
//  SenukaiBookList
//
//  Created by Darius Jankauskas on 29/08/2022.
//  Copyright © 2022 Darius Jankauskas. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

class HomeViewModel {
    
    enum State {
        case idle
        case loading
        case error(Error)
        case loaded([BookList])
    }
    
    var stateObservable: Observable<State> {
        return state.asObservable()
    }
    
    private let loading = BehaviorRelay<Bool>(value: false)
    private let error = BehaviorRelay<Error?>(value: nil)
    private let bookLists = BehaviorRelay<[BookList]>(value: [])
    private let state = BehaviorRelay<State>(value: .idle)
    
    private let apiClient: ApiClient
    private let disposeBag = DisposeBag()
    
    init(apiClient: ApiClient = ApiClient()) {
        self.apiClient = apiClient
    }
    
    func fetchBooksAndLists() {
        state.accept(.loading)
        
        let bookLists = Single.zip(apiClient.makeRequestSingle(endpoint: .books), apiClient.makeRequestSingle(endpoint: .lists)) { [zip] (books: [Book], lists: [List]) in
            zip(lists, books)
        }.asObservable()
        
        bookLists
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] (bookLists: [BookList]) in
                self?.bookLists.accept(bookLists)
                
                let trimmedBookLists = bookLists.map { bookList in
                    BookList(list: bookList.list, books: Array(bookList.books.prefix(5)))
                }
                self?.state.accept(.loaded(trimmedBookLists))
            } onError: { [weak self] error in
                self?.state.accept(.error(error))
                NSLog("%@", "Error: \(error)")
            }.disposed(by: disposeBag)

    }
    
    private func zip(lists: [List], books: [Book]) -> [BookList] {
        let groupedBooks = Dictionary(grouping: books) { book in
            return book.listId
        }
        return lists.map { list in
            BookList(list: list, books: groupedBooks[list.id]!)
        }
    }
}
