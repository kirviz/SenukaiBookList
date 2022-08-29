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
    
    var loadingObservable: Observable<Bool> {
        return loading.distinctUntilChanged().asObservable()
    }
    var errorObservable: Observable<Error?> {
        return error.asObservable()
    }
    var booksObservable: Observable<[BookOverview]> {
        return books.asObservable()
    }
    var stateObservable: Observable<State> {
        return state.asObservable()
    }

    
    private let loading = BehaviorRelay<Bool>(value: false)
    private let error = BehaviorRelay<Error?>(value: nil)
    private let books = BehaviorRelay<[BookOverview]>(value: [])
    private let state = BehaviorRelay<State>(value: .idle)
    
    private let apiClient: ApiClient
    private let disposeBag = DisposeBag()
    
    init(apiClient: ApiClient = ApiClient()) {
        self.apiClient = apiClient
    }

    func fetchBooksOverview() {
        error.accept(nil)
        loading.accept(true)
        
        apiClient.makeRequest(endpoint: .books)
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] (books: [BookOverview]) in
                self?.loading.accept(false)
                self?.books.accept(books)
            } onError: { [weak self] error in
                self?.error.accept(error)
                self?.loading.accept(false)
                NSLog("%@", "Error: \(error)")
            }.disposed(by: disposeBag)

    }
    
    func fetchBooksOverviewState() {
        state.accept(.loading)
        
        let bookLists = Single.zip(apiClient.makeRequestSingle(endpoint: .books), apiClient.makeRequestSingle(endpoint: .lists)) { [zip] (books: [BookOverview], lists: [List]) in
            zip(lists, books)
        }.asObservable()
        
        bookLists
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] (bookLists: [BookList]) in
                self?.state.accept(.loaded(bookLists))
            } onError: { [weak self] error in
                self?.state.accept(.error(error))
                NSLog("%@", "Error: \(error)")
            }.disposed(by: disposeBag)

    }
    
    private func zip(lists: [List], books: [BookOverview]) -> [BookList] {
        let groupedBooks = Dictionary(grouping: books) { book in
            return book.listId
        }
        return lists.map { list in
            BookList(list: list, books: groupedBooks[list.id]!)
        }
    }
}
