//
//  User.swift
//  firebaseChat
//
//  Created by kaka93 on 15/10/2016.
//  Copyright © 2016 MelbUni. All rights reserved.
//


import UIKit

class User: NSObject {
    var id: Int = 0
    var name: String = ""
    var email: String = ""
    var profileImageUrl: String = ""
    var uid: String = ""
    
    init(id:Int, name:String,email:String, profileImageUrl: String) {
        self.id = id
        self.name = name
        self.email = email
        self.profileImageUrl = profileImageUrl
    }
    override init() {
        super.init()
    }
}

