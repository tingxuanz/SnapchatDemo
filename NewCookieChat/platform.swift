//
//  platform.swift
//  NewCookieChat
//
//  Created by Chao Liang on 11/10/16.
//  Copyright © 2016 Chao. All rights reserved.
//

import Foundation

struct Platform {
    
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0 // Use this line in Xcode 7 or newer
    }
    
}
