//
//  Book.swift
//  SenukaiBookList
//
//  Created by Darius Jankauskas on 29/08/2022.
//  Copyright © 2022 Darius Jankauskas. All rights reserved.
//

import Foundation

struct Book: Decodable {
    let id: Int
    let listId: Int
    let title: String
    let img: String
    let author: String?
    let isbn: String?
    let publicationDateString: String?
    let description: String?
    
    private enum CodingKeys : String, CodingKey {
        case id
        case listId = "list_id"
        case title
        case img
        case author
        case isbn
        case publicationDateString = "publication_date"
        case description
    }
    
    var publicationFormattedAsIso: String? {
        let formatter = ISO8601DateFormatter()
        let date = publicationDateString.map { formatter.date(from: $0) }
        
        formatter.formatOptions = [.withFullDate]
        return date?.map { formatter.string(from: $0) }
    }
    
    init(id: Int,
         listId: Int,
         title: String,
         img: String,
         author: String? = nil,
         isbn: String? = nil,
         publicationDateString: String? = nil,
         description: String? = nil) {
        self.id = id
        self.listId = listId
        self.title = title
        self.img = img
        self.author = author
        self.isbn = isbn
        self.publicationDateString = publicationDateString
        self.description = description
    }
    
    init(overview: Book) {
        self.init(id: overview.id, listId: overview.listId, title: overview.title, img: overview.img)
    }
}
