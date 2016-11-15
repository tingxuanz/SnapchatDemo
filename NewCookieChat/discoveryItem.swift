//
//  discoveryItem.swift
//  NewCookieChat
//
//  Created by Chao Liang on 15/10/16.
//  Copyright © 2016 Chao. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class discoverItem{
    var image:UIImage? = nil
    var text:String = ""
    var title:String = ""
    
    init(image:UIImage,text:String,title:String) {
        self.image = image
        self.text = text
        self.title = title
    }
}
