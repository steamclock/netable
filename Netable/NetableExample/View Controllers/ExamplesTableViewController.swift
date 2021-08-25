//
//  ExamplesTableViewController.swift
//  NetableExample
//
//  Created by Brendan on 2020-03-16.
//  Copyright © 2020 Steamclock Software. All rights reserved.
//

import UIKit

class ExamplesTableViewController: UITableViewController {
    private struct RequestRow {
        let title: String
        let vcIdentifier: String
    }

    private struct RequestSet {
        let sectionTitle: String
        let requestRows: [RequestRow]
    }

    private let contents: [RequestSet] = [
        RequestSet(
            sectionTitle: "GET",
            requestRows: [
                RequestRow(title: "GET Cat Image", vcIdentifier: "SampleGetViewController"),
                RequestRow(title: "Download Cat Image", vcIdentifier: "SampleDownloadViewController"),
                RequestRow(title: "Custom Logger Example", vcIdentifier: "CustomLoggerViewController"),
                RequestRow(title: "Empty Logger Example", vcIdentifier: "EmptyLoggerViewController"),
                RequestRow(title: "Decode_snake_case", vcIdentifier: "DecodeSnakeCaseViewController"),
                RequestRow(title: "Cancel Request", vcIdentifier: "CancelRequestViewController"),
                RequestRow(title: "Delete Example", vcIdentifier: "SampleDeleteViewController"),
                RequestRow(title: "Global Error Delegate", vcIdentifier: "GlobalRequestFailureDelegateExample"),
                RequestRow(title: "Global Error Publisher", vcIdentifier: "GlobalRequestFailurePublisherExample")
            ]
        ),
        RequestSet(sectionTitle: "POST", requestRows: [RequestRow(title: "POST Sample Login", vcIdentifier: "PostLoginViewController")]),
    ]

    // MARK: UITableViewDelegate and UITableViewDataSource Overrides

    override func numberOfSections(in tableView: UITableView) -> Int {
        return contents.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return contents[section].sectionTitle
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents[section].requestRows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = contents[indexPath.section].requestRows[indexPath.row].title
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let vc = storyboard?.instantiateViewController(withIdentifier: contents[indexPath.section].requestRows[indexPath.row].vcIdentifier) {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
