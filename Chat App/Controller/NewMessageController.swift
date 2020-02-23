//
//  NewMessageController.swift
//  Chat App
//
//  Created by Apple on 2/23/20.
//  Copyright © 2020 Khaled Elshamy. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {
    
    
    let user = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(back))
        fetchUsersData()
    }
    
    
    func fetchUsersData(){
        let ref = Database.database().reference().child("Users")
        ref.observe(.childAdded, with: { (snapchot) in
            if let dict = snapchot.value as? [String:Any] {
                let user = User()
                user.setValuesForKeys(dict)
                print(user.name, user.email)
            }
        }, withCancel: nil)
    }
    
    @objc func back(){
        self.dismiss(animated: true, completion:nil)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        cell.textLabel?.text = "sdfksdbfkhsd"
        return cell
    }
}
