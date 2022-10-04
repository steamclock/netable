//
//  GraphQLViewController.swift
//  NetableExample
//
//  Created by Brendan on 2022-09-12.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import Combine
import Netable
import UIKit

class GraphQLViewController: UITableViewController {
    private var posts = [Post]()
    private var cancellables = [AnyCancellable]()

    override func viewDidLoad() {
        super.viewDidLoad()

        bindRepository()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        GraphQLRepository.shared.getPosts()

        /// This doesn't actually do anything, but serves as an example of a mutation
        GraphQLRepository.shared.updatePost(id: "1", title: "A new title")
    }

    private func bindRepository() {
        GraphQLRepository.shared.posts
            .sink { posts in
                self.posts = posts
                self.tableView.reloadData()
            }.store(in: &cancellables)
    }
    @IBAction func createNewPost(_ sender: Any) {
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostOverviewCell") as? PostOverviewCell else {
            return UITableViewCell()
        }

        let post = posts[indexPath.row]

        cell.titleLabel.text = post.title
        cell.contentLabel.text = post.content
        return cell
    }
}
