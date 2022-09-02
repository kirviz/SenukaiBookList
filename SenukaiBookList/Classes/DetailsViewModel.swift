//
//  DetailsViewModel.swift
//  SenukaiBookList
//
//  Created by Darius Jankauskas on 31/08/2022.
//  Copyright © 2022 Darius Jankauskas. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

class DetailsViewModel {
    enum State {
        case loading
        case loaded(Book)
        case error(Error)
    }
    
    var book: Book
    
    var stateObservable: Observable<State> {
        return state.asObservable()
    }
    
    private let state: BehaviorRelay<State>
    
    private let apiClient: ApiClient
    private let disposeBag = DisposeBag()
    
    init(book: Book, apiClient: ApiClient = ApiClient()) {
        self.book = book
        self.state = BehaviorRelay<State>(value:.loaded(book))
        self.apiClient = apiClient
    }
    
    func fetchBook(id: Int) {
        state.accept(.loading)
        apiClient.makeRequestSingle(endpoint: .book(id))
            .observe(on: MainScheduler.instance)
            .subscribe { [state, weak self] (book: Book) in
                self?.book = book
                state.accept(.loaded(book))
            } onFailure: { [state] error in
                state.accept(.error(error))
            }.disposed(by: disposeBag)
    }
}
