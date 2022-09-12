//
//  GetAllFilmsQuery.swift
//  NetableExample
//
//  Created by Brendan on 2022-09-12.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Foundation
import Netable

struct Film: Codable {
    let id: String
    let title: String
    let openingCrawl: String
}

struct GetAllFilmsResponse: Codable {
    let data: ResponseData

    struct ResponseData: Codable {
        let allFilms: AllFilms

        struct AllFilms: Codable {
            let films: [Film]
        }
    }
}

struct GetAllFilmsQuery: GraphQLRequest {
    typealias RawResource = GetAllFilmsResponse
    typealias FinalResource = [Film]

    func finalize(raw: GetAllFilmsResponse) -> Result<[Film], NetableError> {
        .success(raw.data.allFilms.films)
    }
}
