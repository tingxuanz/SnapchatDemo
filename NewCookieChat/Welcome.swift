import UIKit
import Firebase
import CoreData

class Welcome: UIViewController{
    
//    var messagesController: MessagesController?
    static let sharedInstance = AppState()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Log In", message:"Input the Username and Password.",preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Login", style: .default, handler:{ (action: UIAlertAction) in
            let emailField = alert.textFields?[0]
            let passwordField = alert.textFields?[1]
            let email = (emailField?.text)!
            let password = (passwordField?.text)!
            self.doLogin(email: email,password: password)
//            self.doLogin(email: "chao@test.com", password: "123456")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (action: UIAlertAction) in
            // do
        }))
        alert.addTextField(configurationHandler: { (text: UITextField) in
            text.placeholder = "Email"
            text.textAlignment = .center
        })
        alert.addTextField(configurationHandler:  { (text: UITextField) in
            text.placeholder = "Password"
            text.textAlignment = .center
            text.isSecureTextEntry = true
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func signin(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Sign Up", message:"",preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Sign", style: .default, handler:{ (action: UIAlertAction) in
            let usernameField = alert.textFields?[0]
            let passwordField = alert.textFields?[1]
            let repasswoerField = alert.textFields?[2]
            let emailField = alert.textFields?[3]
            let username = (usernameField?.text)!
            let password = (passwordField?.text)!
            let repassword = (repasswoerField?.text)!
            let email = (emailField?.text)!
            self.doSign(username: username, password: password, email: email,repassword: repassword)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (action: UIAlertAction) in
            // do
        }))
        alert.addTextField(configurationHandler: { (text: UITextField) in
            text.placeholder = "Username"
            text.textAlignment = .center
        })
        alert.addTextField(configurationHandler:  { (text: UITextField) in
            text.placeholder = "Password"
            text.textAlignment = .center
            text.isSecureTextEntry = true
        })
        alert.addTextField(configurationHandler:  { (text: UITextField) in
            text.placeholder = "Re-enter Password"
            text.textAlignment = .center
            text.isSecureTextEntry = true
        })
        alert.addTextField(configurationHandler:  { (text: UITextField) in
            text.placeholder = "Email"
            text.textAlignment = .center
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func doLogin(email:String, password:String) -> Void {
        //do
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
            
            if error != nil {
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            let uid = user?.uid
            let ref = FIRDatabase.database().reference()
            
            var username:String=""
            var email:String=""
            var userId:Int=0
            
            ref.child("users").child((uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                username = value?.object(forKey: "name") as! String
                email = value?.object(forKey: "email") as! String
                userId = value?.object(forKey: "id") as! Int
                print(username,userId,email)
                self.logSuccess(username: username, email: email, userId: userId)
                
                
            }) { (error) in
                print(error.localizedDescription)
                return
            }
//            self.logSuccess(username: username, email: email, userId: userId)
        })
        
    }
    
    func doSign(username:String, password:String, email:String, repassword:String) -> Void {
        //do
        if(password == repassword){
            FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
                if error != nil {
                    let alert = UIAlertController(title: "Error", message: error as? String, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                guard let uid = user?.uid else {
                    return
                }
                let userId:Int = Int(arc4random())
                let values = ["name": username, "email": email, "id": userId] as [String : Any]
                self.registerUserIntoDatabaseWithUID(uid, values: values as [String : AnyObject])
                
                self.logSuccess(username: username, email: email, userId: Int(userId))
            })
        }
    }
    
    func registerUserIntoDatabaseWithUID(_ uid: String, values: [String: AnyObject]) {
        let ref = FIRDatabase.database().reference()
        let usersReference = ref.child("users").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print(err)
                return
            }
            
            let user = User()
            user.setValuesForKeys(values)
        })
    }
    
    func signedIn(username:String, email:String, userId:Int) {
//        AppState.init()
        print(username,email,userId)
        AppState.sharedInstance.displayName = username
        AppState.sharedInstance.signedIn = true
        AppState.sharedInstance.email = email
        AppState.sharedInstance.userId = userId
    }
    
    func logSuccess(username:String, email:String, userId:Int) {
        self.signedIn(username: username, email:email, userId: userId)
        performSegue(withIdentifier: "loginSuccess", sender: self)
    }
    
    
}
