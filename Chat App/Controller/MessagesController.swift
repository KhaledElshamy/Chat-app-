//
//  ViewController.swift
//  Chat App
//
//  Created by Khaled Elshamy on 11/4/19.
//  Copyright © 2019 Khaled Elshamy. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


class MessagesController: UITableViewController {

    var messages: Set<String> = []
    var MyContacts = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(logOut))
        let image = #imageLiteral(resourceName: "new_message_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        CheckIfUserIsLogin()
        tableView.register(UsersCell.self, forCellReuseIdentifier: "cellId")
        print(self.MyContacts.count)
    }
    
    
    @objc func handleNewMessage(){
        let vc = NewMessageController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    
    func CheckIfUserIsLogin(){
        // user isn't logged in
        if Auth.auth().currentUser?.uid == nil {
            performSelector(onMainThread: #selector(logOut), with: nil, waitUntilDone: true)
        }else {
           FetchUserAndSetupNavBarTitle()
        }
    }
    
    
    func FetchUserAndSetupNavBarTitle(){
        observeMessages()
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference().child("users").child(uid)
        ref.observe(.value, with: { (snapchot) in
            if let dict = snapchot.value as? [String:Any] {
                self.navigationItem.title = dict["name"] as? String
            }
        }, withCancel: nil)
    }
    
    
    func observeMessages(){
        let ref = Database.database().reference().child("messages")
        ref.observe(.childAdded, with: { (snapchot) in
            if let dict = snapchot.value as? [String:Any] {
                if !self.messages.contains(dict["sendToId"] as! String){
                    self.messages.insert(dict["sendToId"] as! String)
                    self.getMyContacts()
                }
            }
        }, withCancel: nil)
        
    }
    
    
    func getMyContacts(){
        let ref2 = Database.database().reference().child("users")
           ref2.observe(.childAdded, with: { (snapchot) in
               if let dict = snapchot.value as? [String:Any] {
                if self.messages.contains(snapchot.key) {
                       //print(snapchot.key)
                       let user = User()
                       user.email = dict["email"] as? String
                       user.name = dict["name"] as? String
                       user.profileImageUrl = dict["profileImageUrl"] as? String
                       user.id  = snapchot.key
                       self.MyContacts.append(user)
                   }
                   self.tableView.reloadData()
               }
           }, withCancel: nil)
    }
    
    @objc func logOut(){
        
        do{
            try Auth.auth().signOut()
        }catch let logoutError {
            print(logoutError)
        }
        
        let LoginVC = LoginController()
        LoginVC.messagesController = self
        LoginVC.modalPresentationStyle = .fullScreen
        present(LoginVC, animated: true, completion: nil)
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return self.MyContacts.count
       }
       
       override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! UsersCell
           cell.textLabel?.text = self.MyContacts[indexPath.item].name
           cell.detailTextLabel?.text = self.MyContacts[indexPath.item].email
           if let profileImageUrl = MyContacts[indexPath.item].profileImageUrl {
               cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
           }
           return cell
       }
       
       override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           let vc = ChatMessagesController()
           vc.user = self.MyContacts[indexPath.item]
           self.navigationController?.pushViewController(vc, animated: true )
       }
       
       override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
              return 72
       }
    
}

