//
//  ApiClientMock.swift
//  RoundUpTests
//
//  Created by Darius Jankauskas on 24/08/2022.
//  Copyright © 2022 Darius Jankauskas. All rights reserved.
//

import XCTest
@testable import SenukaiBookList

class ApiClientMock: ApiClient {
    override func makeRequest<T>(endpoint: Endpoint, callBack: @escaping (Result<T, Error>) -> ()) where T : Decodable {
        switch endpoint {
        case .books:
            callBack(.success([BookOverview(id: 1, listId: 1, title: "Book 1", img: ""), BookOverview(id: 2, listId: 1, title: "Book 2", img: ""), BookOverview(id: 3, listId: 2, title: "Book 3", img: "")] as! T))
        case .lists:
            callBack(.success([List(id: 1, title: "One"), List(id: 2, title: "Two")] as! T))
        default:
            fatalError("mock not implemented")
        }
    }
}
