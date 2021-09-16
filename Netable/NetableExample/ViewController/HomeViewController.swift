//
//  HomeViewController.swift
//  NetableExample
//
//  Created by Brendan on 2021-09-14.
//  Copyright © 2021 Steamclock Software. All rights reserved.
//

import Combine
import UIKit

class HomeViewController: UITableViewController {
    private var posts = [Post]()
    private var cancellables = [AnyCancellable]()

    override func viewDidLoad() {
        super.viewDidLoad()

        bindRepository()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        PostRepository.shared.getPosts()
    }

    private func bindRepository() {
        PostRepository.shared.posts.sink { posts in
            self.posts = posts
            self.tableView.reloadData()
        }.store(in: &cancellables)
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
