//
//  StarWarsRepository.swift
//  NetableExample
//
//  Created by Brendan on 2022-09-12.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Combine
import Foundation
import Netable

class StarWarsRepository {
    static var shared = StarWarsRepository()
    let netable = Netable(baseURL: URL(string: "https://swapi-graphql.netlify.app/.netlify/functions/")!)

    var films: CurrentValueSubject<[Film], Never>

    private init() {
        films = CurrentValueSubject<[Film], Never>([])
    }

    func getFilms() {
        netable.request(GetAllFilmsQuery()) { result in
            switch result {
            case .success(let films):
                self.films.send(films)
            case .failure(let error):
                print("failure: \(error.localizedDescription)")
            }
        }
    }
}
