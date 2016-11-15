//
//  discoveryCollectionViewCell.swift
//  NewCookieChat
//
//  Created by Chao Liang on 15/10/16.
//  Copyright © 2016 Chao. All rights reserved.
//

import UIKit

class discoverySmallCell: UICollectionViewCell {
    var imageshow:UIImageView = UIImageView()
    let fullScreenSize = UIScreen.main.bounds.size
    override func awakeFromNib() {
        let w = Double(UIScreen.main.bounds.size.width)
        self.imageshow = UIImageView(frame: CGRect(x:0,y:0,width: fullScreenSize.width/3 - 20, height: fullScreenSize.width/3 - 20 ))
        print(self.bounds)
        self.imageshow.contentMode = .scaleAspectFill
        self.addSubview(imageshow)
    }
}
