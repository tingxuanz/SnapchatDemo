//
//  StoryView.swift
//  NewCookieChat
//
//  Created by Chao Liang on 17/10/16.
//  Copyright © 2016 Chao. All rights reserved.
//

import UIKit
import Firebase

class StoryView: UIViewController {
    
    let cellId = "cellId"
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    @IBOutlet weak var tableView: UITableView!
    var users = [User]() //存储current user的好友
    var requests = [friendRequest]()//好友请求存储在这里，需要展示出来  friendRequest是自己写的类，仿照User
    var friendStories = [UserStory]()//friend的story存储在这里，需要展示出来 UserStory是自己写的类，仿照User
    var publicStories = [PublicStory]()//存储public story， 需要展示出来

    override func viewDidLoad() {
        super.viewDidLoad()

        let swipeGestureRecognizerLEFT: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.toRight))
        let swipeGestureRecognizerRIGHT: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.toLeft))
        swipeGestureRecognizerLEFT.direction = UISwipeGestureRecognizerDirection.left
        swipeGestureRecognizerRIGHT.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeGestureRecognizerRIGHT)
        self.view.addGestureRecognizer(swipeGestureRecognizerLEFT)
        
        fetchFriendStories()
        fetchAllPublicStories()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func fetchAllPublicStories(){
        FIRDatabase.database().reference().child("publicStory").observe(.childAdded, with: { (snapshot) -> Void in
            
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let publicStory = PublicStory()
                publicStory.id = snapshot.key
                
                //if you use this setter, your app will crash if your class properties don't exactly match up with the firebase dictionary keys
                publicStory.setValuesForKeys(dictionary)
                self.publicStories.append(publicStory)
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }
            
        })
    }
    
    //获取所有好友发的所有story
    func fetchFriendStories(){
        let currentUserId = FIRAuth.auth()?.currentUser?.uid
        FIRDatabase.database().reference().child("friends").child(currentUserId!).observe(.childAdded, with: { (snapshot) -> Void in
            if snapshot.value as? Bool == true {
                let friendId = snapshot.key
                FIRDatabase.database().reference().child("userStory").observe(.childAdded, with: { (snapshot) -> Void in
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        if dictionary["senderId"] as! String == friendId{
                            let friendStory = UserStory()
                            friendStory.setValuesForKeys(dictionary)
                            self.friendStories.append(friendStory)
                            
                        }
                        //if you use this setter, your app will crash if your class properties don't exactly match up with the firebase dictionary keys
                        //user.setValuesForKeys(dictionary)
                        //self.users.append(user)
                        
                        
//                        DispatchQueue.main.async(execute: {
//                            self.collectionView?.reloadData()
//                        })
                        print(self.friendStories.count)
                    }
                    
                })
            }
        })
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendStories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! storyCell
        let UserStory = friendStories[indexPath.row]
        cell.name.text = UserStory.name
        return cell
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userStory = friendStories[indexPath.item]
        let imageView = UIImageView()
        FIRStorage.storage().reference(forURL: userStory.imageUrl!).data(withMaxSize: 25 * 1024 * 1024, completion: { (data, error) -> Void in
            imageView.image = UIImage(data: data!)
        })
        self.performZoomInForStartingImageView(imageView)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "storyToDis"){
            let dis = segue.destination as! discoveryCollectionViewController
            dis.items = publicStories
        }
    }

    func toLeft() {
        self.performSegue(withIdentifier: "storyToMain", sender: self)
    }
    func toRight() {
        self.performSegue(withIdentifier: "storyToDis", sender: self)
    }

    @IBAction func backToMain(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "storyToMain", sender: self)
    }
    @IBAction func goToDis(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "storyToDis", sender: self)
    }
}
