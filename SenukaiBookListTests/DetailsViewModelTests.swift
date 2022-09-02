//
//  DetailsViewModelTests.swift
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

extension DetailsViewModel.State: Equatable {
    public static func == (lhs: DetailsViewModel.State, rhs: DetailsViewModel.State) -> Bool {
        switch lhs {
        case .loading:
            if case .loading = rhs {
                return true
            }
            return false
        case .error(let lhsError):
            if case .error(let rhsError) = rhs {
                return String(describing: lhsError) == String(describing: rhsError)
            }
            return false
        case .loaded(let lhsBook):
            if case .loaded(let rhsBook) = rhs {
                return lhsBook == rhsBook
            }
            return false
        }
    }
}

class DetailsViewModelTests: XCTestCase {
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

    func testFetchBookSuccess() throws {
        let apiMock = ApiClientMock()
        let viewModel = DetailsViewModel(book: Book(id: 0, listId: 0, title: "", img: ""), apiClient: apiMock)
        
        viewModel.fetchBook(id: 1)
        XCTAssertEqual(try viewModel.stateObservable.toBlocking().first(), .loaded(M.book1))
        viewModel.fetchBook(id: 2)
        XCTAssertEqual(try viewModel.stateObservable.toBlocking().first(), .loaded(M.book2))
    }
    
    func testFetchBookError() throws {
        let apiMock = ApiClientErrorMock()
        let viewModel = DetailsViewModel(book: Book(id: 0, listId: 0, title: "", img: ""), apiClient: apiMock)
        
        viewModel.fetchBook(id: 1)
        XCTAssertEqual(try viewModel.stateObservable.toBlocking().first(), .error(NetworkingError.malformedRequest))
    }

    func testFetchBookSequenceSuucesAndError() throws {
        let apiMock = ApiClientMock()
        let emptyBook = Book(id: 0, listId: 0, title: "", img: "")
        let viewModel = DetailsViewModel(book: emptyBook, apiClient: apiMock)

        let state = scheduler.createObserver(DetailsViewModel.State.self)
        
        viewModel.stateObservable
          .bind(to: state)
          .disposed(by: disposeBag)
        
        viewModel.fetchBook(id: 1)
        viewModel.fetchBook(id: 2)
        viewModel.fetchBook(id: 0)
        viewModel.fetchBook(id: 3)
        
        XCTAssertEqual(state.events, [
            .next(0, .loaded(emptyBook)),
            .next(0, .loading),
            .next(0, .loaded(M.book1)),
            .next(0, .loading),
            .next(0, .loaded(M.book2)),
            .next(0, .loading),
            .next(0, .error(NetworkingError.malformedRequest)),
            .next(0, .loading),
            .next(0, .loaded(M.book3)),
        ])
    }
}
