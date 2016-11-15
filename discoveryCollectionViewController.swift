//
//  discoveryCollectionViewController.swift
//  NewCookieChat
//
//  Created by Chao Liang on 15/10/16.
//  Copyright © 2016 Chao. All rights reserved.
//

import UIKit
import Firebase

class discoveryCollectionViewController: UICollectionViewController {
    
    let fullScreenSize = UIScreen.main.bounds.size
    var items:Array<PublicStory>?
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(50, 10, 10, 10);
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: CGFloat(fullScreenSize.width)/3 - 20.0,height: CGFloat(fullScreenSize.width)/3 - 20.0)
        self.collectionView?.collectionViewLayout = layout
        
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height:64))
        let navigationItem = UINavigationItem()
        
        let leftButton =  UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.backToStory))
        
        navigationItem.leftBarButtonItem = leftButton
        navigationBar.items = [navigationItem]
        self.view.addSubview(navigationBar)
        collectionView?.frame.origin.y += 64
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let small = collectionView.dequeueReusableCell(withReuseIdentifier: "small", for: indexPath as IndexPath) as! discoverySmallCell
        let publicStory = items?[indexPath.item]
        FIRStorage.storage().reference(forURL: (publicStory?.imageUrl!)!).data(withMaxSize: 25 * 1024 * 1024, completion: { (data, error) -> Void in
            small.imageshow.image = UIImage(data: data!)
        })
        return small
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items!.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! discoverySmallCell
        self.performZoomInForStartingImageView(cell.imageshow)
    }
//
//    // change background color when user touches cell
//    override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
//        let cell = collectionView.cellForItem(at: indexPath)
//        cell?.backgroundColor = UIColor.red
//    }
//    
//    // change background color back when user releases touch
//    override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
//        let cell = collectionView.cellForItem(at: indexPath)
//        cell?.backgroundColor = UIColor.cyan
//    }
    func backToStory() {
        self.performSegue(withIdentifier: "disToStory", sender: self)
    }
    func performZoomInForStartingImageView(_ startingImageView: UIImageView) {
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
            
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackBackgroundView?.alpha = 1
                
                // math?
                // h2 / w1 = h1 / w1
                // h2 = h1 / w1 * w1
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                
                zoomingImageView.center = keyWindow.center
                
                }, completion: { (completed) in
                    //                    do nothing
            })
            
        }
    }
    
    func handleZoomOut(_ tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            //need to animate back out to controller
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                
                }, completion: { (completed) in
                    zoomOutImageView.removeFromSuperview()
                    self.startingImageView?.isHidden = false
            })
        }
    }

}
