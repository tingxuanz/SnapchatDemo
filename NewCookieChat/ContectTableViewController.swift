//
//  ContectTableViewController.swift
//  CookieChat
//
//  Created by Chao Liang on 8/10/2016.
//  Copyright © 2016 Chao. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class ContectTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    
    @IBOutlet var contactTable: UITableView!
    var users: Array<User> = []
    var ref = FIRDatabase.database().reference()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchFriend()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue:240.0/255.0, alpha: 0.8)
        
//        let fetchRequest = NSFetchRequest(entityName: "Contact")
//        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
//        fetchRequest.sortDescriptors = [sortDescriptor]
//        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
//            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
//            fetchResultController.delegate = self
//            do {
//                try fetchResultController.performFetch()
//                contactList = fetchResultController.fetchedObjects as! [contactClass]
//            } catch {
//                print(error)
//            }
//        }
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
                    })
                }) { (error) in
                    print(error.localizedDescription)
                    return
                }
                
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactTableViewCell
        let user = users[(indexPath as NSIndexPath).row]
        cell.nameLabel.text = user.name
        cell.lastTimeLabel.text = user.email
        
        let profileImageUrl = user.profileImageUrl
        if(profileImageUrl.isEmpty){
            cell.contactImageView.image = UIImage(named: "Contects")
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    
    // 添加动作到cell 当点击的时候从屏幕底部出现菜单
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        // Create an option menu as an action sheet
//        let optionMenu = UIAlertController(title: nil, message: "What do you want to do?", preferredStyle: .Alert)
//        // Add actions to the menu
//        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler:nil)
//        optionMenu.addAction(cancelAction)
    
        
        // 需要修改 使用。。。
        // Call action
//        let callActionHandler = { (action:UIAlertAction!) -> Void in
//            let alertMessage = UIAlertController(title: "Service Unavailable", message: "Sorry, the call feature is not available yet. Please retry later.", preferredStyle: .Alert)
//            alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
//            self.presentViewController(alertMessage, animated: true, completion: nil)
//        }
//        let callAction = UIAlertAction(title: "Call " + "123-000-\(indexPath.row)", style: UIAlertActionStyle.Default, handler: callActionHandler)
//        optionMenu.addAction(callAction)
        
        // 标记操作
//        let isVisitedAction = UIAlertAction(title: "I've been here", style: .Default,
//            handler: {(action:UIAlertAction!) -> Void in
//            let cell = tableView.cellForRowAtIndexPath(indexPath)
//            cell?.accessoryType = .Checkmark
//        })
//        optionMenu.addAction(isVisitedAction)
        
        
        // Display the menu
//        self.presentViewController(optionMenu, animated: true, completion: nil)
//        
//        tableView.deselectRowAtIndexPath(indexPath, animated: false)
//    }
    
//    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        if editingStyle == .Delete {
//            // Delete the row from the data source
//            contactList.removeAtIndex(indexPath.row)
//        }
//        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
//    }
    
//    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath
//        indexPath: NSIndexPath) -> [UITableViewRowAction]? {
//        // Social Sharing Button
//        let shareAction = UITableViewRowAction(style:
//            UITableViewRowActionStyle.Default, title: "Share", handler: { (action,
//                indexPath) -> Void in
//                let defaultText = "Just checking in at " +
//                    self.contactList[indexPath.row].name
//                let activityController = UIActivityViewController(activityItems:
//                    [defaultText], applicationActivities: nil)
//                self.presentViewController(activityController, animated: true,
//                    completion: nil)
//        })
//        // Delete button
//        let deleteAction = UITableViewRowAction(style:
//            UITableViewRowActionStyle.Default, title: "Delete",handler: { (action,
//                indexPath) -> Void in
//                // Delete the row from the data source
//                self.contactList.removeAtIndex(indexPath.row)
//                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:
//                    .Fade)
//        })
//        shareAction.backgroundColor = UIColor(red: 28.0/255.0, green: 165.0/255.0,blue: 253.0/255.0, alpha: 1.0)
//        deleteAction.backgroundColor = UIColor(red: 202.0/255.0, green: 202.0/255.0,blue: 203.0/255.0, alpha: 1.0)
//        return [deleteAction, shareAction]
//    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "showContactDetail" {
//            if let indexPath = tableView.indexPathForSelectedRow {
//                let destinationController = segue.destination as! ContactDetailViewController
//                destinationController.contact = contactList[indexPath.row]
//            }
//        }
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = true
    }
    
    @IBAction func unwindToHomeScreen(segue:UIStoryboardSegue) {
    }
    
//    func controllerWillChangeContent(controller: NSFetchedResultsController<AnyObject>) {
//        tableView.beginUpdates()
//    }
//    func controller(controller: NSFetchedResultsController, didChangeObject
//        anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type:
//        NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
//        switch type {
//        case .Insert:
//            if let _newIndexPath = newIndexPath {
//                tableView.insertRowsAtIndexPaths([_newIndexPath], withRowAnimation: .Fade)
//            }
//        case .Delete:
//            if let _indexPath = indexPath {
//                tableView.deleteRowsAtIndexPaths([_indexPath], withRowAnimation: .Fade)
//            }
//        case .Update:
//            if let _indexPath = indexPath {
//                tableView.reloadRowsAtIndexPaths([_indexPath], withRowAnimation: .Fade)
//            }
//        default:
//            tableView.reloadData()
//        }
//        contactList = controller.fetchedObjects as! [contactClass]
//    }
//    
//    func controllerDidChangeContent(controller: NSFetchedResultsController) {
//        tableView.endUpdates()
//    }

}
