//
//  StarWarsViewController.swift
//  NetableExample
//
//  Created by Brendan on 2022-09-12.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Combine
import Netable
import UIKit

class StarWarsViewController: UITableViewController {
    private var films = [Film]()
    private var cancellables = [AnyCancellable]()

    private let netable = Netable(baseURL: URL(string: "https://swapi-graphql.netlify.app/.netlify/functions/")!)

    override func viewDidLoad() {
        super.viewDidLoad()

        bindRepository()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        StarWarsRepository.shared.getFilms()
    }

    private func bindRepository() {
        StarWarsRepository.shared.films.sink { films in
            self.films = films
            self.tableView.reloadData()
        }.store(in: &cancellables)
    }
    @IBAction func createNewPost(_ sender: Any) {
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return films.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostOverviewCell") as? PostOverviewCell else {
            return UITableViewCell()
        }

        let films = films[indexPath.row]

        cell.titleLabel.text = films.title
        cell.contentLabel.text = films.openingCrawl
        return cell
    }
}
