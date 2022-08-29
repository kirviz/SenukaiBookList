//
//  CachedRequest.swift
//  SenukaiBookList
//
//  Created by Darius Jankauskas on 29/08/2022.
//  Copyright © 2022 Darius Jankauskas. All rights reserved.
//

import Foundation

class CachedRequest {
    static let cache = URLCache(memoryCapacity: 40 * 1024 * 1024,
                                diskCapacity: 512 * 1024 * 1024,
                                diskPath: "urlCache")

    static func request(url: URL, completion: @escaping (Data?, Bool)->() ) -> URLSessionTask? {
        let request = URLRequest(url: url,
                                 cachePolicy: .returnCacheDataElseLoad,
                                 timeoutInterval: 100)

        if let cacheResponse = cache.cachedResponse(for: request) {
            completion(cacheResponse.data, true)
            return nil
        } else {
            let config = URLSessionConfiguration.default

            config.urlCache = cache
            
            let session = URLSession(configuration: config)
            
            let task = session.dataTask(with: request) { data, response, error in
                if let response = response, let data = data {
                    let cacheResponse = CachedURLResponse(response: response, data: data)
                    cache.storeCachedResponse(cacheResponse, for: request)
                }
                
                completion(data, false)
            }
            task.resume()
            return task
        }
    }
}
