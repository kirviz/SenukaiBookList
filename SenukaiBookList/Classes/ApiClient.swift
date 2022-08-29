//
//  RestClient.swift
//  RoundUp
//
//  Created by Darius Jankauskas on 09/08/2022.
//  Copyright © 2022 Darius Jankauskas. All rights reserved.
//

import Foundation
import RxSwift

enum NetworkingError: Error {
    case malformedRequest
    case noResponse
    case networkError(Error)
    case httpError(Int, String)
    case noData
    case decodingError(Error)
}

class ApiClient {
    func makeRequest<T: Decodable>(endpoint: Endpoint, callBack: @escaping (Result<T, Error>)->()) {
        guard let request = endpoint.request else {
            callBack(.failure(NetworkingError.malformedRequest))
            return
        }
        
        let requestDescription = request.url?.absoluteString ?? ""
        let bodyDescription = String(decoding: (request.httpBody ?? Data()), as: UTF8.self)
        NSLog("\nNetworkRequest: %@\nwithBody: %@", requestDescription, bodyDescription)
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                callBack(.failure(NetworkingError.networkError(error)))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                callBack(.failure(NetworkingError.noResponse))
                return
            }
            
            guard (200 ..< 300) ~= response.statusCode else {
                var message = ""
                if let data = data {
                    message = String(decoding: data, as: UTF8.self)
                }
                callBack(.failure(NetworkingError.httpError(response.statusCode, message)))
                return
            }
            
            guard let data = data else {
                callBack(.failure(NetworkingError.noData))
                return
            }
            
            do {
                let value = try JSONDecoder().decode(T.self, from: data)
                callBack(.success(value))
            }
            catch (let error) {
                callBack(.failure(NetworkingError.decodingError(error)))
            }
        }
        task.resume()
    }
}

extension ApiClient {
    func makeRequestSingle<T: Decodable>(endpoint: Endpoint) -> Single<T> {
        return Single.create { observer in
            self.makeRequest(endpoint: endpoint) { (result: Result<T, Error>) in
                observer(result)
            }
            return Disposables.create()
        }
    }
    
    func makeRequest<T: Decodable>(endpoint: Endpoint) -> Observable<T> {
        return makeRequestSingle(endpoint: endpoint).asObservable()
    }
}
