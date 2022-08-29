//
//  BookOverview.swift
//  SenukaiBookList
//
//  Created by Darius Jankauskas on 29/08/2022.
//  Copyright © 2022 Darius Jankauskas. All rights reserved.
//

import Foundation

struct BookOverview: Decodable {
    let id: Int
    let listId: Int
    let title: String
    let img: String
    
    private enum CodingKeys : String, CodingKey {
        case id
        case listId = "list_id"
        case title
        case img
    }
}