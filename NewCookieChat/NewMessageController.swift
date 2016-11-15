import UIKit
import Firebase


class NewMessageController: UITableViewController {
    
    let cellId = "cellId"
    
    var users = [User]() //存储current user的好友
    var requests = [friendRequest]()//好友请求存储在这里，需要展示出来  friendRequest是自己写的类，仿照User
    var friendStories = [UserStory]()//friend的story存储在这里，需要展示出来 UserStory是自己写的类，仿照User
    var publicStories = [PublicStory]()//存储public story， 需要展示出来
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        
        //addFriend()
        //fetchFriendRequest()
        //agreeFriendRequest()
        //fetchFriend()
        //fetchFriendStories()
        fetchAllPublicStories()
        
    }
    
    //获取全部public story
    func fetchAllPublicStories(){
        FIRDatabase.database().reference().child("publicStory").observe(.childAdded, with: { (snapshot) -> Void in
            
            
             if let dictionary = snapshot.value as? [String: AnyObject] {
             let publicStory = PublicStory()
             publicStory.id = snapshot.key
             
             //if you use this setter, your app will crash if your class properties don't exactly match up with the firebase dictionary keys
             publicStory.setValuesForKeys(dictionary)
             self.publicStories.append(publicStory)
             
             //this will crash because of background thread, so lets use dispatch_async to fix
             DispatchQueue.main.async(execute: {
             self.tableView.reloadData()
             })
             print(self.publicStories.count)
             //                user.name = dictionary["name"]
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
                        
                       
                        DispatchQueue.main.async(execute: {
                            self.tableView.reloadData()
                        })
                        
                        //                user.name = dictionary["name"]
                    }
                    
                })
            }
        })
    }
    
    
    func fetchFriend(){
        let currentUserId = FIRAuth.auth()?.currentUser?.uid
        FIRDatabase.database().reference().child("friends").child(currentUserId!).observe(.childAdded, with: { (snapshot) -> Void in
            if snapshot.value as? Bool == true {
                let targetUserID = snapshot.key
                FIRDatabase.database().reference().child("users").child(targetUserID).observe(.value, with: { (snapshot) -> Void in
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        let user = User()
                        user.uid = snapshot.key
                        
                        //if you use this setter, your app will crash if your class properties don't exactly match up with the firebase dictionary keys
                        user.setValuesForKeys(dictionary)
                        self.users.append(user)
                        
                        //this will crash because of background thread, so lets use dispatch_async to fix
                        DispatchQueue.main.async(execute: {
                            self.tableView.reloadData()
                        })
                        print(self.users.count)
                        //                user.name = dictionary["name"]
                    }
                    
                })
            }
        })
    }
    
    func addFriend() {
        let targetUserName = "test@firebase.com"//此输入为测试，需要改为从输入框得到的用户输入
        let currentUserId : String = (FIRAuth.auth()?.currentUser?.uid)!
        
        
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: {(snapshot) -> Void in
            let dictionary = snapshot.value as? [String: AnyObject]
            let targetEmail = dictionary?["email"] as! String
            if targetUserName == targetEmail {
                let targetUserId = snapshot.key
//                FIRDatabase.database().reference().child("friends").child(targetUserId).child("requestFrom").updateChildValues([currentUserId: true])
            }
        })
        
    }
    func fetchFriendRequest(){
        let currentUserId = FIRAuth.auth()?.currentUser?.uid
        FIRDatabase.database().reference().child("friends").child(currentUserId!).child("requestFrom").observe(.childAdded, with: { (snapshot) -> Void in
            if snapshot.value as? Bool == true {
                let targetUserID = snapshot.key
                FIRDatabase.database().reference().child("users").child(targetUserID).observe(.value, with: { (snapshot) -> Void in
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        let request = friendRequest()
                        request.fromId = snapshot.key
                        
                        //if you use this setter, your app will crash if your class properties don't exactly match up with the firebase dictionary keys
                        request.setValuesForKeys(dictionary)
                        //self.friendRequests.append(request)
                        self.requests.append(request)
                        //this will crash because of background thread, so lets use dispatch_async to fix
                        DispatchQueue.main.async(execute: {
                            self.tableView.reloadData()
                        })
                        
                        //                user.name = dictionary["name"]
                    }
                    
                })
            }
        })
    }
    func agreeFriendRequest(){
        let requestFromId = "VXCWUURVVYd0uKcIuXvFSSjbjhL2"//测试，实际应为从界面读取的信息
        let currentUserId = FIRAuth.auth()?.currentUser?.uid
        
        FIRDatabase.database().reference().child("friends").child(currentUserId!).updateChildValues([requestFromId: true]) //当前用户同意后，把发送请求用户添加进好友
        FIRDatabase.database().reference().child("friends").child(requestFromId).updateChildValues([currentUserId!: true]) //发送请求的用户数据库中也要把当前用户添加进好友
        FIRDatabase.database().reference().child("friends").child(currentUserId!).child("requestFrom").child(requestFromId).removeValue() //添加结束后删除request信息
    }
    
    
    func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let user = users[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
//        if let profileImageUrl = user.profileImageUrl {
//            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
//        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
//    var messagesController: MessagesController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            print("Dismiss completed")
            let user = self.users[(indexPath as NSIndexPath).row]
//            self.messagesController?.showChatControllerForUser(user)
        }
    }
    
}
