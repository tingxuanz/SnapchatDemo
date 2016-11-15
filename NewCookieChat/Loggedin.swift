//
//  Loggedin.swift
//  NewCookieChat
//
//  Created by Chao Liang on 17/10/16.
//  Copyright © 2016 Chao. All rights reserved.
//

import Foundation
import CoreData

class Loggedin: NSManagedObject {
    @NSManaged var email: String
    @NSManaged var password: String
}
