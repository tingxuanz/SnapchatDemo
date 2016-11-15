//
//  ContactDetailViewController.swift
//  CookieChat
//
//  Created by Chao Liang on 9/10/2016.
//  Copyright © 2016 Chao. All rights reserved.
//

import UIKit
import Firebase

class ContactDetailViewController: UIViewController {
    
    @IBOutlet var contactImageView:UIImageView!
    @IBOutlet var contactNameDisplay: UILabel!
    @IBOutlet var contactChatIdDisplay: UILabel!
    @IBOutlet var contactEmail: UILabel!
    var contact:User = User()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if(contact.profileImageUrl.isEmpty){
            contactImageView.image = UIImage(named: "Contects")
        }
        contactNameDisplay.text = contact.name
        let chatIdString:String = "ChatID"
        contactChatIdDisplay.text = "\(chatIdString)\(String(contact.id))"
        contactEmail.text = "Email:" + contact.email
        let swipeGestureRecognizerUP: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.toUp))
        swipeGestureRecognizerUP.direction = UISwipeGestureRecognizerDirection.up
        self.view.addGestureRecognizer(swipeGestureRecognizerUP)
        
        title = "User Detail"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func cam(_ sender: AnyObject) {
        performSegue(withIdentifier: "detailToMain", sender: self)
    }
    
    @IBAction func logout(_ sender: AnyObject){
        let alert = UIAlertController(title: "LOGOUT", message: "Sure to logging out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
            let firebaseAuth = FIRAuth.auth()
            do {
                try firebaseAuth?.signOut()
                AppState.sharedInstance.signedIn = false
//                self.dismiss(animated: true, completion: nil)
                self.performSegue(withIdentifier: "logout", sender: self)
            } catch let signOutError as NSError {
                print ("Error signing out: \(signOutError.localizedDescription)")
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction) in
            // do
        }))
        self.present(alert, animated: true, completion: nil)
    }
    func toUp() {
        self.performSegue(withIdentifier: "detailToMain", sender: self)
    }

}
