//
//  ListViewModelTests.swift
//  SenukaiBookListTests
//
//  Created by Darius Jankauskas on 02/09/2022.
//  Copyright © 2022 Darius Jankauskas. All rights reserved.
//

import XCTest
@testable import SenukaiBookList
import RxSwift
import RxBlocking
import RxTest

extension ListViewModel.State: Equatable {
    public static func == (lhs: ListViewModel.State, rhs: ListViewModel.State) -> Bool {
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

class ListViewModelTests: XCTestCase {
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
        let homeViewModel = HomeViewModel(apiClient: apiMock)
        let viewModel = ListViewModel(homeViewModel: homeViewModel, apiClient: apiMock)
        
        let bookList1 = BookList(list: M.list1, books: [M.book1, M.book2])
        let bookList2 = BookList(list: M.list2, books: [M.book3])
        
        viewModel.refresh()
        XCTAssertEqual(try viewModel.stateObservable(listId: 1).toBlocking().first(), .loaded(bookList1))
        XCTAssertEqual(try viewModel.stateObservable(listId: 2).toBlocking().first(), .loaded(bookList2))
    }

    func testBookLists3() throws {
        let apiMock = ApiClientMock()
        apiMock.books = [M.book3]
        let homeViewModel = HomeViewModel(apiClient: apiMock)
        let viewModel = ListViewModel(homeViewModel: homeViewModel, apiClient: apiMock)

        let bookList1 = BookList(list: M.list1, books: [])
        let bookList2 = BookList(list: M.list2, books: [M.book3])
        
        viewModel.refresh()
        XCTAssertEqual(try viewModel.stateObservable(listId: 1).toBlocking().first(), .loaded(bookList1))
        XCTAssertEqual(try viewModel.stateObservable(listId: 2).toBlocking().first(), .loaded(bookList2))
    }
    
    func testBookListsNoLists() throws {
        let apiMock = ApiClientMock()
        apiMock.lists = []
        let homeViewModel = HomeViewModel(apiClient: apiMock)
        let viewModel = ListViewModel(homeViewModel: homeViewModel, apiClient: apiMock)

        let error = ListViewModel.BookListError.bookListNotFound
        
        viewModel.refresh()
        XCTAssertEqual(try viewModel.stateObservable(listId: 1).toBlocking().first(), .error(error))
        XCTAssertEqual(try viewModel.stateObservable(listId: 2).toBlocking().first(), .error(error))
    }
    
    func testSuccessfulStateSequence() throws {
        let apiMock = ApiClientMock()
        let homeViewModel = HomeViewModel(apiClient: apiMock)
        let viewModel = ListViewModel(homeViewModel: homeViewModel, apiClient: apiMock)

        let state = scheduler.createObserver(ListViewModel.State.self)
        
        viewModel.stateObservable(listId: 1)
          .bind(to: state)
          .disposed(by: disposeBag)
        
        viewModel.refresh()
        
        let bookList1 = BookList(list: M.list1, books: [M.book1, M.book2])
        
        XCTAssertEqual(state.events, [
            .next(0, .idle),
            .next(0, .loading),
            .next(0, .loaded(bookList1)),
        ])
    }
    
    func testSuccessfulStateSequenceTwice() throws {
        let apiMock = ApiClientMock()
        let homeViewModel = HomeViewModel(apiClient: apiMock)
        let viewModel = ListViewModel(homeViewModel: homeViewModel, apiClient: apiMock)

        let state = scheduler.createObserver(ListViewModel.State.self)
        
        viewModel.stateObservable(listId: 1)
          .bind(to: state)
          .disposed(by: disposeBag)
        
        viewModel.refresh()
        viewModel.refresh()
        
        let bookList1 = BookList(list: M.list1, books: [M.book1, M.book2])
        
        XCTAssertEqual(state.events, [
            .next(0, .idle),
            .next(0, .loading),
            .next(0, .loaded(bookList1)),
            .next(0, .loading),
            .next(0, .loaded(bookList1)),
        ])
    }
    
    func testErrorStateSequence() throws {
        let apiMock = ApiClientErrorMock()
        let homeViewModel = HomeViewModel(apiClient: apiMock)
        let viewModel = ListViewModel(homeViewModel: homeViewModel, apiClient: apiMock)


        let state = scheduler.createObserver(ListViewModel.State.self)
        
        viewModel.stateObservable(listId: 1)
          .bind(to: state)
          .disposed(by: disposeBag)
        
        viewModel.refresh()
        
        XCTAssertEqual(state.events, [
            .next(0, .idle),
            .next(0, .loading),
            .next(0, .error(NetworkingError.malformedRequest)),
        ])
    }
}
