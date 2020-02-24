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

        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(logOut))
        let image = #imageLiteral(resourceName: "new_message_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        CheckIfUserIsLogin()
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
            let uid = Auth.auth().currentUser!.uid
            print(uid)
            let ref = Database.database().reference().child("users").child(uid)
            ref.observe(.value, with: { (snapchot) in
                if let dict = snapchot.value as? [String:Any] {
                    self.navigationItem.title = dict["name"] as? String
                }
            }, withCancel: nil)
        }
    }
    
    @objc func logOut(){
        
        do{
            try Auth.auth().signOut()
        }catch let logoutError {
            print(logoutError)
        }
        
        let LoginVC = LoginController()
        LoginVC.modalPresentationStyle = .fullScreen
        present(LoginVC, animated: true, completion: nil)
    }
}

