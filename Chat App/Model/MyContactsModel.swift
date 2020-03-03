//
//  MyContactsModel.swift
//  Chat App
//
//  Created by Apple on 2/26/20.
//  Copyright © 2020 Khaled Elshamy. All rights reserved.
//

import UIKit
import Firebase

class MyContactsMessages: NSObject {

    var fromId: String?
    var text: String?
    var date: String?
    var toId: String?
    var name:String?
    var timestamp: NSNumber?
    var imageUrl: String?
    var imageHeight:NSNumber?
    var imageWidth:NSNumber?
    
    init(dictionary: [String: Any]) {
        self.fromId = dictionary["fromId"] as? String
        self.text = dictionary["text"] as? String
        self.toId = dictionary["sendToId"] as? String
        self.date = dictionary["date"] as? String
        self.name = dictionary["name"] as? String
        self.timestamp = dictionary["timestamp"] as? NSNumber
        self.imageUrl = dictionary["imageUrl"] as? String
        self.imageHeight = dictionary["imageHeight"] as? NSNumber
        self.imageWidth = dictionary["imageWidth"] as? NSNumber
    }
    
    func chatPartnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
}

