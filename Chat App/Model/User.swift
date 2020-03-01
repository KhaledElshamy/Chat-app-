//
//  User.swift
//  Chat App
//
//  Created by Apple on 2/23/20.
//  Copyright © 2020 Khaled Elshamy. All rights reserved.
//

import UIKit


class User:NSObject {
    var name:String?
    var email:String?
    var profileImageUrl: String?
    var id: String?
    init(dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String
        self.name = dictionary["name"] as? String
        self.email = dictionary["email"] as? String
        self.profileImageUrl = dictionary["profileImageUrl"] as? String
    }
}
