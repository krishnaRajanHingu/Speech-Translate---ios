//
//  LanguageTableViewController.swift
//  SpeechTranslate
//
//  Created by Krishna Hingu on 6/6/19.
//  Copyright © 2019 Krishna Hingu. All rights reserved.
//

import UIKit

class LanguageTableViewController: UITableViewController {
    var tapHandler: ((Int)->())?
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) ->
        Int {
            // #warning Incomplete implementation, return the number of rows
            return 5
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.tapHandler != nil {
            self.tapHandler!(indexPath.row)
        }
        self.dismiss(animated: true, completion: nil)
    }
}
