//
//  ListWithBooks.swift
//  SenukaiBookList
//
//  Created by Darius Jankauskas on 29/08/2022.
//  Copyright © 2022 Darius Jankauskas. All rights reserved.
//

import Foundation

struct BookList: Decodable, Equatable {
    let list: List
    let books: [Book]
}
