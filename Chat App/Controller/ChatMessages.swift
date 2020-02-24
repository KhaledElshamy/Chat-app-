//
//  ChatMessages.swift
//  Chat App
//
//  Created by Apple on 2/24/20.
//  Copyright © 2020 Khaled Elshamy. All rights reserved.
//

import UIKit


class ChatMessagesVontroller:UITableViewController {    
    
    fileprivate let cellId = "id123"
    
     let chatMessages = [
           ChatMessage(text: "Here's my very first message", isIncoming: true),
           ChatMessage(text: "I'm going to message another long message that will word wrap", isIncoming: true),
           ChatMessage(text: "I'm going to message another long message that will word wrap, I'm going to message another long message that will word wrap, I'm going to message another long message that will word wrap", isIncoming: false),
           ChatMessage(text: "Yo, dawg, Whaddup!", isIncoming: false),
           ChatMessage(text: "This message should appear on the left with a white background bubble", isIncoming: true),
       ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Messages"
       // navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: cellId)
        tableView.separatorStyle = .none
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatMessageCell
        let chatMessage = chatMessages[indexPath.row]
                
        cell.chatMessage = chatMessage
        return cell
    }


}
