//
//  friendList.swift
//  NewCookieChat
//
//  Created by Chao Liang on 17/10/16.
//  Copyright © 2016 Chao. All rights reserved.
//

import UIKit
import Firebase

class friendList: UIViewController, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var tableView: UITableView!
    
    var sentImage:UIImage = UIImage()
    var enableEdit = false
    var selectedList:Array<String> = []
    
    var dataSet:Int = 0
    //var templeUserArray:Array<User> = []
    var templeUserArray = [User]()
    var users: Array<User> = []
    var ref = FIRDatabase.database().reference()
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchFriend()
        
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height:64))
        let navigationItem = UINavigationItem()
        navigationItem.title = "MyFriend"
        
        
        if(enableEdit == false){
            let leftButton =  UIBarButtonItem(title: "Search", style: .plain, target: self, action: #selector(self.addfriend(_:)))
            let rightButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.toRight))
            navigationItem.leftBarButtonItem = leftButton
            navigationItem.rightBarButtonItem = rightButton
        }else{
            let rightButton = UIBarButtonItem(title: "OK", style: .plain, target: self, action: #selector(self.send))
            navigationItem.rightBarButtonItem = rightButton
        }
        navigationBar.items = [navigationItem]
        self.view.addSubview(navigationBar)
        tableView.frame.origin = CGPoint(x:0, y:64)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue:240.0/255.0, alpha: 0.8)
        
        tableView.delegate = self
        tableView.dataSource = self
        let swipeGestureRecognizerLEFT: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.toRight))
        swipeGestureRecognizerLEFT.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeGestureRecognizerLEFT)
        if(enableEdit == false){
            self.navigationItem.leftBarButtonItem?.isEnabled = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchFriend(){
        let currentUserId = FIRAuth.auth()?.currentUser?.uid
        ref.child("friends").child(currentUserId!).observe(.childAdded, with: { (snapshot) -> Void in
            if snapshot.value as? Bool == true{
                let targetUserID = snapshot.key
                self.ref.child("users").child(targetUserID).observeSingleEvent(of: .value, with: { (snapshot) in
                    let value = snapshot.value as? NSDictionary
                    let username = value?.object(forKey: "name") as! String
                    let email = value?.object(forKey: "email") as! String
                    let userId = value?.object(forKey: "userId") as! Int
                    let user = User(id: userId, name: username, email: email, profileImageUrl: "")
                    user.uid = targetUserID
                    self.users.append(user)
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                        self.dataSet = 0
                    })
                }) { (error) in
                    print(error.localizedDescription)
                    return
                }
                
            }
        })
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(dataSet == 0){
            return users.count
        }
        if(dataSet == 1){
            return templeUserArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactTableViewCell
        var source:Array<User> = []
        if(dataSet == 0){
            source = users
        }else if(dataSet == 1){
            source = templeUserArray
        }
        let user = source[(indexPath as NSIndexPath).row]
        cell.nameLabel.text = user.name
        cell.lastTimeLabel.text = user.email
        
        let profileImageUrl = user.profileImageUrl
        if(profileImageUrl.isEmpty){
            cell.contactImageView.image = UIImage(named: "Contects")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    @IBAction func addfriend(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Add Friend", message:"",preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler:{ (action: UIAlertAction) in
            let keyField = alert.textFields?[0]
            let keyword = (keyField?.text)!
            self.templeUserArray = []
            self.searchFriend(keyWord: keyword)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (action: UIAlertAction) in
            // do
        }))
        alert.addTextField(configurationHandler: { (text: UITextField) in
            text.placeholder = "Email OR ChatID OR Username"
            text.textAlignment = .center
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func searchFriend(keyWord: String) {
//        let currentUserId: String = (FIRAuth.auth()?.currentUser?.uid)!
        var count = 0
        
        self.ref.child("users").observe(.childAdded, with: {(snapshot) -> Void in
            let dictionary = snapshot.value as? [String: AnyObject]
            let targetEmail = dictionary?["email"] as! String
            let targetName = dictionary?["name"] as! String
            let targetIdInt = dictionary?["id"] as! Int
            let targetIdString = String(targetIdInt)
            if(keyWord == targetEmail || keyWord == targetName || keyWord == targetIdString){
                count += 1
                let currentUserId : String = (FIRAuth.auth()?.currentUser?.uid)!
                let targetUserId = snapshot.key
            FIRDatabase.database().reference().child("friends").child(targetUserId).child("requestFrom").updateChildValues([currentUserId: true])
                let user = User(id: targetIdInt, name: targetName, email: targetEmail, profileImageUrl: "")
                user.uid = snapshot.key
                print(user)
                self.templeUserArray.append(user)
                print(self.templeUserArray.count,"count")
                self.dataSet = 1
                DispatchQueue.main.async(execute: {
                    self.tableView.clearsContextBeforeDrawing = true
                    self.tableView.reloadData()
                })
            }
        })
        
    }
    @IBOutlet weak var search: UIBarButtonItem!
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(enableEdit == false){
            if(dataSet == 0){
                self.performSegue(withIdentifier: "toChat", sender: self)
            }
            if(dataSet == 1){
                let targetUserName = templeUserArray[indexPath.row].uid
                let currentUserId : String = (FIRAuth.auth()?.currentUser?.uid)!
                FIRDatabase.database().reference().child("users").observe(.childAdded, with: {(snapshot) -> Void in
                let dictionary = snapshot.value as? [String: AnyObject]
                let targetEmail = dictionary?["email"] as! String
                if targetUserName == targetEmail {
                    let targetUserId = snapshot.key
                    FIRDatabase.database().reference().child("friends").child(targetUserId).child("requestFrom").updateChildValues([currentUserId: true])
                    }
                })
                    
                
            }
        }
    }
    func send() {
        for toId in selectedList{
            if let selectedImage:UIImage = sentImage {
                uploadToFirebaseStorageUsingImage(selectedImage, completion: { (imageUrl) in
                    let ref = FIRDatabase.database().reference().child("messages")
                    let childRef = ref.childByAutoId()
                    childRef.updateChildValues(["imageUrl": imageUrl as AnyObject, "imageWidth": self.sentImage.size.width as AnyObject, "imageHeight": self.sentImage.size.height as AnyObject,"toId": toId as AnyObject, "fromId": FIRAuth.auth()!.currentUser!.uid as AnyObject, "timestamp": NSNumber(value:Date().timeIntervalSince1970)])
                })
            }
        }
        dismiss(animated: true, completion: nil)
    }
    fileprivate func uploadToFirebaseStorageUsingImage(_ image: UIImage, completion: @escaping (_ imageUrl: String) -> ()) {
        let imageName = UUID().uuidString
        let ref = FIRStorage.storage().reference().child("message_images").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            ref.put(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    print("Failed to upload image:", error)
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    completion(imageUrl)
                }
                
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toChat" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! CollectionViewController
                destinationController.user = users[indexPath.row]
                
            }
        }
    }
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if(enableEdit == true){
            selectedList.append(self.users[indexPath.row].uid)
            let cell = tableView.cellForRow(at: indexPath) as! ContactTableViewCell
            cell.backgroundColor = .yellow
        }
    }
    func toRight() {
        self.performSegue(withIdentifier: "friendToMain", sender: self)
    }

}
