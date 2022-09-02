//
//  BookListTests.swift
//  SenukaiBookListTests
//
//  Created by Darius Jankauskas on 01/09/2022.
//  Copyright © 2022 Darius Jankauskas. All rights reserved.
//

import XCTest
@testable import SenukaiBookList
import RxSwift
import RxBlocking
import RxTest

extension HomeViewModel.State: Equatable {
    public static func == (lhs: HomeViewModel.State, rhs: HomeViewModel.State) -> Bool {
        switch lhs {
        case .loading:
            if case .loading = rhs {
                return true
            }
            return false
        case .idle:
            if case .idle = rhs {
                return true
            }
            return false
        case .error(let lhsError):
            if case .error(let rhsError) = rhs {
                return String(describing: lhsError) == String(describing: rhsError)
            }
            return false
        case .loaded(let lhsBookList):
            if case .loaded(let rhsBookList) = rhs {
                return lhsBookList == rhsBookList
            }
            return false
        }
    }
}

class HomeViewModelTests: XCTestCase {
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }

    override func tearDownWithError() throws {
        scheduler = nil
        disposeBag = nil
    }

    func testBookLists123() throws {
        let apiMock = ApiClientMock()
        let viewModel = HomeViewModel(apiClient: apiMock)
        
        let bookLists = [BookList(list: M.list1, books: [M.book1, M.book2]),
                         BookList(list: M.list2, books: [M.book3])]
        
        viewModel.fetchBooksAndLists()
        XCTAssertEqual(try viewModel.stateObservable.toBlocking().first(), .loaded(bookLists))
    }

    func testBookLists1333() throws {
        let apiMock = ApiClientMock()
        apiMock.books = [M.book1, M.book3, M.book3, M.book3]
        let viewModel = HomeViewModel(apiClient: apiMock)
        
        let bookLists = [BookList(list: M.list1, books: [M.book1]),
                         BookList(list: M.list2, books: [M.book3, M.book3, M.book3])]
        
        viewModel.fetchBooksAndLists()
        XCTAssertEqual(try viewModel.stateObservable.toBlocking().first(), .loaded(bookLists))
    }
    
    func testBookLists3() throws {
        let apiMock = ApiClientMock()
        apiMock.books = [M.book3]
        let viewModel = HomeViewModel(apiClient: apiMock)
        
        let bookLists = [BookList(list: M.list1, books: []),
                         BookList(list: M.list2, books: [M.book3])]
        
        viewModel.fetchBooksAndLists()
        XCTAssertEqual(try viewModel.stateObservable.toBlocking().first(), .loaded(bookLists))
    }
    
    func testBookListsNoBooks() throws {
        let apiMock = ApiClientMock()
        apiMock.books = []
        let viewModel = HomeViewModel(apiClient: apiMock)
        
        let bookLists = [BookList(list: M.list1, books: []),
                         BookList(list: M.list2, books: [])]
        
        viewModel.fetchBooksAndLists()
        XCTAssertEqual(try viewModel.stateObservable.toBlocking().first(), .loaded(bookLists))
    }
    
    func testBookListsNoLists() throws {
        let apiMock = ApiClientMock()
        apiMock.books = [M.book1, M.book2, M.book2]
        apiMock.lists = []
        let viewModel = HomeViewModel(apiClient: apiMock)
        
        let bookLists: [BookList] = []
        
        viewModel.fetchBooksAndLists()
        XCTAssertEqual(try viewModel.stateObservable.toBlocking().first(), .loaded(bookLists))
    }
    
    func testBookListsNoBooksNorLists() throws {
        let apiMock = ApiClientMock()
        apiMock.books = []
        apiMock.lists = []
        let viewModel = HomeViewModel(apiClient: apiMock)
        
        let bookLists: [BookList] = []
        
        viewModel.fetchBooksAndLists()
        XCTAssertEqual(try viewModel.stateObservable.toBlocking().first(), .loaded(bookLists))
    }
    
    func testSuccessfulStateSequence() throws {
        let viewModel = HomeViewModel(apiClient: ApiClientMock())

        let state = scheduler.createObserver(HomeViewModel.State.self)
        
        viewModel.stateObservable
          .bind(to: state)
          .disposed(by: disposeBag)
        
        viewModel.fetchBooksAndLists()
        
        let bookLists = [BookList(list: M.list1, books: [M.book1, M.book2]),
                         BookList(list: M.list2, books: [M.book3])]
        
        XCTAssertEqual(state.events, [
            .next(0, .idle),
            .next(0, .loading),
            .next(0, .loaded(bookLists)),
        ])
    }
    
    func testSuccessfulStateSequenceTwice() throws {
        let viewModel = HomeViewModel(apiClient: ApiClientMock())

        let state = scheduler.createObserver(HomeViewModel.State.self)
        
        viewModel.stateObservable
          .bind(to: state)
          .disposed(by: disposeBag)
        
        viewModel.fetchBooksAndLists()
        viewModel.fetchBooksAndLists()
        
        let bookLists = [BookList(list: M.list1, books: [M.book1, M.book2]),
                         BookList(list: M.list2, books: [M.book3])]
        
        XCTAssertEqual(state.events, [
            .next(0, .idle),
            .next(0, .loading),
            .next(0, .loaded(bookLists)),
            .next(0, .loading),
            .next(0, .loaded(bookLists)),
        ])
    }
    
    func testErrorStateSequence() throws {
        let viewModel = HomeViewModel(apiClient: ApiClientErrorMock())

        let state = scheduler.createObserver(HomeViewModel.State.self)
        
        viewModel.stateObservable
          .bind(to: state)
          .disposed(by: disposeBag)
        
        viewModel.fetchBooksAndLists()
        
        XCTAssertEqual(state.events, [
            .next(0, .idle),
            .next(0, .loading),
            .next(0, .error(NetworkingError.malformedRequest)),
        ])
    }
}
