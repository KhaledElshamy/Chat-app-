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
    
    
    var user = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(back))
        fetchUsersData()
        tableView.register(UsersCell.self, forCellReuseIdentifier: "cellId")
        self.tableView.separatorStyle = .none
    }
    
    func fetchUsersData(){
        let ref = Database.database().reference().child("users")
        ref.observe(.childAdded, with: { (snapchot) in
            if let dict = snapchot.value as? [String:Any] {
               // print(dict)
                let user = User(dictionary: dict)
                user.id  = snapchot.key
                self.user.append(user)
                self.tableView.reloadData()
            }
        }, withCancel: nil)
    }
    
    @objc func back(){
        self.dismiss(animated: true, completion:nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.user.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! UsersCell
        cell.textLabel?.text = self.user[indexPath.item].name
        cell.detailTextLabel?.text = self.user[indexPath.item].email
        if let profileImageUrl = user[indexPath.item].profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ChatMessagesController()

        vc.user = user[indexPath.item]
        if let toId = self.user[indexPath.item].id {
            vc.sendToId = toId
        }
        
        self.navigationController?.pushViewController(vc, animated: true )
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           return 72
    }
}
