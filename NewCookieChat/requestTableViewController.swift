//
//  requestTableViewController.swift
//  
//
//  Created by Chao Liang on 18/10/16.
//
//

import UIKit
import Firebase

class requestTableViewController: UITableViewController {

    var requests:Array<friendRequest> = []
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchFriendRequest()
        
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height:64))
        let navigationItem = UINavigationItem()
        navigationItem.title = "Request"
        let leftButton =  UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.back))
        navigationItem.leftBarButtonItem = leftButton
        navigationBar.items = [navigationItem]
        self.view.addSubview(navigationBar)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return requests.count
        
    }
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactTableViewCell
        var source:Array<friendRequest> = []
        //var request:friendRequest = requests[indexPath.row]
        source = requests
        let friendRequest = source[(indexPath as NSIndexPath).row]
        cell.nameLabel.text = friendRequest.name
        cell.lastTimeLabel.text = friendRequest.email
        return cell
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fromId = requests[indexPath.row].fromId
        agreeFriendRequest(fromId: fromId!)
        tableView.cellForRow(at: indexPath)?.backgroundColor = UIColor.gray
    }
    func fetchFriendRequest(){
        let currentUserId = FIRAuth.auth()?.currentUser?.uid
        FIRDatabase.database().reference().child("friends").child(currentUserId!).child("requestFrom").observe(.childAdded, with: { (snapshot) -> Void in
            if snapshot.value as? Bool == true {
                let targetUserID = snapshot.key
                FIRDatabase.database().reference().child("users").child(targetUserID).observe(.value, with: { (snapshot) -> Void in
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        print(dictionary)
                        let request = friendRequest()
                        request.fromId = snapshot.key
                        request.userId = dictionary["userId"] as! Int?
                        request.id = dictionary["id"] as! Int?
                        request.name = dictionary["name"] as! String?
                        request.email = dictionary["email"] as! String?
                        //request.setValuesForKeys(dictionary)
                        
                        
                        //if you use this setter, your app will crash if your class properties don't exactly match up with the firebase dictionary keys
                        //request.setValuesForKeys(dictionary)
                        //self.friendRequests.append(request)
                        self.requests.append(request)
                        print(self.requests.count)
                        //this will crash because of background thread, so lets use dispatch_async to fix
                        DispatchQueue.main.async(execute: {
                            self.tableView.reloadData()
                        })
                    }
                    
                })
            }
        })
    }
    func agreeFriendRequest(fromId:String){
        let requestFromId = fromId
        let currentUserId = FIRAuth.auth()?.currentUser?.uid
        
        FIRDatabase.database().reference().child("friends").child(currentUserId!).updateChildValues([requestFromId: true]) //当前用户同意后，把发送请求用户添加进好友
        FIRDatabase.database().reference().child("friends").child(requestFromId).updateChildValues([currentUserId!: true]) //发送请求的用户数据库中也要把当前用户添加进好友
        FIRDatabase.database().reference().child("friends").child(currentUserId!).child("requestFrom").child(requestFromId).removeValue() //添加结束后删除request信息
    }
    func back() {
        performSegue(withIdentifier: "backToDetail", sender: self)
    }
    

}
