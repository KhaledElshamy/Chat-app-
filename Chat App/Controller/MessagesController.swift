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


fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

class MessagesController: UITableViewController {

    var MyContacts = [User]()
    var messages = [MyContactsMessages]()
    var messagesDictionary = [String: MyContactsMessages]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(logOut))
        let image = #imageLiteral(resourceName: "new_message_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        CheckIfUserIsLogin()
        tableView.register(UsersCell.self, forCellReuseIdentifier: "cellId")
        print(self.MyContacts.count)
        self.tableView.separatorStyle = .none
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
        self.messages.removeAll()
        self.messagesDictionary.removeAll()

        ObserevUserMessages()
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
    
    
    func ObserevUserMessages(){
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference().child("user_messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            print(messageId)
            let messagegeRef = Database.database().reference().child("messages").child(messageId)
            messagegeRef.observe(.value, with: { (snapshot) in
                if let dict = snapshot.value as? [String:Any] {
                    let message = MyContactsMessages(dictionary: dict)
                    if let told = message.chatPartnerId() {
                        self.messagesDictionary[told] = message
                        self.messages = Array(self.messagesDictionary.values)
                        self.messages.sort(by: { (message1, message2) -> Bool in
                            return message1.timestamp?.int32Value > message2.timestamp?.int32Value
                        })
                 }
                    self.tableView.reloadData()
                }
            }, withCancel: nil)
            
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
           return self.messages.count
       }
       
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! UsersCell
        let message = messages[indexPath.row]
        cell.message = message
        return cell
    }
       
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ChatMessagesController()
        let message = messages[indexPath.row]
              
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
              
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
        guard let dictionary = snapshot.value as? [String: AnyObject] else {
            return
        }
                  
        let user = User(dictionary: dictionary)
            user.id = chatPartnerId
            vc.user = user
        }, withCancel: nil)
        
        if let id = message.chatPartnerId() {
            vc.sendToId = id
        }
        
        self.navigationController?.pushViewController(vc, animated: true )
    }
       
       override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
              return 72
       }
    
}

