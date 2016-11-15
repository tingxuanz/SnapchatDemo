
import Foundation

class AppState: NSObject {

    static let sharedInstance = AppState()

    var signedIn = false
    var displayName: String!
//  var photoURL: URL?
    var userId:Int!
    var email:String!
    
//    override init() {
//        self.signedIn = true
//        self.displayName = "test"
//        self.email = " test@test.com"
//        self.userId = 000
//    }
    func method() {
        print(type(of: self).sharedInstance)
    }
}
