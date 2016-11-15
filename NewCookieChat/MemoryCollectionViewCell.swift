//
//  MemoryCollectionViewCell.swift
//  NewCookieChat
//
//  Created by Chao Liang on 16/10/16.
//  Copyright © 2016 Chao. All rights reserved.
//

import UIKit

class MemoryCollectionViewCell: UICollectionViewCell {
    var imageshow:UIImageView = UIImageView()
    override func awakeFromNib() {
//        self.imageshow = UIImageView(frame: CGRect(x:0,y:0,width: size.width, height: size.width ))
//        self.imageshow.contentMode = .scaleAspectFill
        self.addSubview(imageshow)
    }
}
