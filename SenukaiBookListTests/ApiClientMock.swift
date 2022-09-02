//
//  ApiClientMock.swift
//  RoundUpTests
//
//  Created by Darius Jankauskas on 24/08/2022.
//  Copyright © 2022 Darius Jankauskas. All rights reserved.
//

import XCTest
@testable import SenukaiBookList

typealias M = ApiClientMock

class ApiClientErrorMock: ApiClient {
    override func makeRequest<T>(endpoint: Endpoint, callBack: @escaping (Result<T, Error>) -> ()) where T : Decodable {
        callBack(.failure(NetworkingError.malformedRequest))
    }
}

class ApiClientMock: ApiClient {
    
    static let book1 = Book(id: 1, listId: 1, title: "Book 1", img: "")
    static let book2 = Book(id: 2, listId: 1, title: "Book 2", img: "")
    static let book3 = Book(id: 3, listId: 2, title: "Book 3", img: "")
    
    static let list1 = List(id: 1, title: "One")
    static let list2 = List(id: 2, title: "Two")
    
    var books = [book1, book2, book3]
    
    var lists = [list1, list2]
    
    override func makeRequest<T>(endpoint: Endpoint, callBack: @escaping (Result<T, Error>) -> ()) where T : Decodable {
        switch endpoint {
        case .books:
            callBack(.success(books as! T))
        case .lists:
            callBack(.success(lists as! T))
        case .book(let bookId):
            switch bookId {
            case 1: callBack(.success(M.book1 as! T))
            case 2: callBack(.success(M.book2 as! T))
            case 3: callBack(.success(M.book3 as! T))
            default: callBack(.failure(NetworkingError.malformedRequest))
            }
        }
    }
}
