//
//  Endpoint.swift
//  RoundUp
//
//  Created by Darius Jankauskas on 09/08/2022.
//  Copyright © 2022 Darius Jankauskas. All rights reserved.
//

import Foundation

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    
    var value: String { return rawValue }
}

enum Endpoint {
    private static let baseURL = URL(string: "https://my-json-server.typicode.com/KeskoSenukaiDigital/assignment")!
    
    case books
    case book(Int)
    case lists
    
    struct Values {
        // Using vars instead of lets as a cheeky way to generate all possible initialisers.
        // I am aware this can be frowned upon but I think it's reasonable.
        // I wouldn't go against team guidelines of course.
        var method: HttpMethod = .get
        let path: String
        var queryParams: [String:String]?
        var body: Data?
    }
    
    private var values: Values {
        switch self {
        case .books:
            return Values(path: "/books")
        case .book(let bookId):
            return Values(path: "/book/\(bookId)")
        case .lists:
            return Values(path: "/lists")
        }
    }
}

extension Endpoint {
    var request: URLRequest? {
        let properties = self.values
        
        let urlString = "\(Endpoint.baseURL)\(properties.path)"
        
        guard var urlComponents = URLComponents(string: urlString) else {
            return nil
        }
        
        urlComponents.queryItems = properties.queryParams?.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        
        guard let finalUrl = urlComponents.url else {
            return nil
        }
        
        var request = URLRequest(url: finalUrl)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.httpMethod = properties.method.value
        request.httpBody = properties.body
        
        return request
    }
}
