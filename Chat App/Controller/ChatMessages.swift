//
//  ChatMessages.swift
//  Chat App
//
//  Created by Apple on 2/24/20.
//  Copyright © 2020 Khaled Elshamy. All rights reserved.
//

import UIKit


class ChatMessagesController:UITableViewController {
    
    fileprivate let cellId = "id123"
    
    let chatMessages = [
         [
             ChatMessage(text: "Here's my very first message", isIncoming: true, date: Date.dateFromCustomString(customString: "08/03/2018")),
             ChatMessage(text: "I'm going to message another long message that will word wrap", isIncoming: true, date: Date.dateFromCustomString(customString: "08/03/2018")),
         ],
         [
             ChatMessage(text: "I'm going to message another long message that will word wrap, I'm going to message another long message that will word wrap, I'm going to message another long message that will word wrap", isIncoming: false, date: Date.dateFromCustomString(customString: "09/15/2018")),
             ChatMessage(text: "Yo, dawg, Whaddup!", isIncoming: false, date: Date()),
             ChatMessage(text: "This message should appear on the left with a white background bubble", isIncoming: true, date: Date.dateFromCustomString(customString: "09/15/2018")),
         ],
         [
             ChatMessage(text: "Third Section message", isIncoming: true, date: Date.dateFromCustomString(customString: "10/31/2018"))
         ]
     ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Messages"
        
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: cellId)
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        self.tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return chatMessages.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let firstMessageInSection = chatMessages[section].first {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let dateString = dateFormatter.string(from: firstMessageInSection.date)
           let label = DateHeaderLabel()
            label.text = dateString
            
            let containerView = UIView()
            
            containerView.addSubview(label)
            label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
            
            return containerView
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return chatMessages[section].count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatMessageCell
        let chat = chatMessages[indexPath.section][indexPath.row]
                
        cell.chatMessage = chat
        return cell
    }


}
