//
//  NewPostViewController.swift
//  NetableExample
//
//  Created by Brendan on 2021-09-16.
//  Copyright © 2021 Steamclock Software. All rights reserved.
//

import UIKit

class NewPostViewController: UIViewController {
    @IBOutlet var titleField: UITextField!
    @IBOutlet var contentField: UITextView!

    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func submit(_ sender: Any) {
        guard let title = titleField.text,
              let content = contentField.text else {
            return
        }

        PostRepository.shared.create(title, content: content) {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
