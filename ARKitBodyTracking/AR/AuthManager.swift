import Firebase
import FirebaseUI
import FBSDKLoginKit

protocol AuthDelegate {
    mutating func didSigned(_ authManager: AuthManager, error: Error?) -> Void
}

class AuthManager: NSObject, FUIAuthDelegate {
    public var userToken = ""
    public var userId = ""
    public var userDisplayName = ""
    public var authUI: FUIAuth!
    
    private var isUserSigned = false
    public var delegate: AuthDelegate?
    public func isSigned() -> Bool {
        return self.isUserSigned
    }
    
    override init() {
        super.init()
        
        authUI = FUIAuth.defaultAuthUI()!
        authUI.delegate = self
        let providers: [FUIAuthProvider] = [
            FUIFacebookAuth(authUI: authUI,
                            permissions: ["public_profile",
                                          "publish_video",
                                          "email"
                            ])
        ]
        authUI.providers = providers
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        self.userToken = ""
        self.userId = ""
        self.isUserSigned = false
        if let error = error {
            self.delegate?.didSigned(self, error: error)
            return
        }
        
        self.userToken = (AccessToken.current?.tokenString ?? "")
        self.userId = (authDataResult?.user.providerData[0].uid ?? "")
        self.userDisplayName = (authDataResult?.user.displayName ?? "")
        self.isUserSigned = true
        print("[AccountSystem.authUI]::token: \(self.userToken), uid: \(self.userId), displayName: \(self.userDisplayName)")
        self.delegate?.didSigned(self, error: nil)
    }
    
    func signOut() {
        _ = try? authUI.signOut()
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        return self.handleOpenUrl(url, sourceApplication: sourceApplication)
    }
    
    @available(iOS 8.0, *)
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return self.handleOpenUrl(url, sourceApplication: sourceApplication)
    }
    
    func handleOpenUrl(_ url: URL, sourceApplication: String?) -> Bool {
        return self.authUI.handleOpen(url, sourceApplication: sourceApplication)
    }
}
