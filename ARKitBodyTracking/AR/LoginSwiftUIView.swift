import SwiftUI
import Firebase
import FBSDKLoginKit

struct LoginSwiftUIView: View {
    @State var doLogin: Bool = false
    @State var gotoARScene: Bool = false
    
    @ObservedObject var userData: UserData
    private let authManager: AuthManager = AuthManager()
    
    init() {
        userData = UserData.shared
        authManager.delegate = self
    }
    
    private var DoLoginView: some View {
        return VStack {
            Button(action: {self.doLogin = true}) {
                Text("LOGIN")
                    .padding()
                    .background(Color.white)
            }
        }.sheet(isPresented: self.$doLogin) {
            AuthViewController(authUI: self.authManager.authUI)
        }
    }
    
    private var StartARView: some View {
        return VStack {
            Button(action: {self.gotoARScene = true}) {
                Text("START")
                    .padding()
                    .background(Color.white)
            }
            
            Button(action: {
                self.authManager.signOut()
                self.userData.signOut()
            } , label: {
                Text("SIGNOUT")
                    .padding()
                    .background(Color.gray)
            })
        }.fullScreenCover(isPresented: $gotoARScene) {
            UIViewWrapper(storyboard: "Storyboard", viewController: "arVC")
        }
    }
    
    var body: some View {
        Group {
            if userData.isLogin {
                StartARView
            } else {
                DoLoginView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .onAppear() {
            if let currentUser = Auth.auth().currentUser {
                self.userData.uid = currentUser.providerData[0].uid
                self.userData.displayName = currentUser.displayName ?? "User"
                self.userData.token = AccessToken.current?.tokenString ?? ""
                
                self.userData.isLogin = self.userData.token != ""
                userData.dump()
            }
        }
    }
}

extension LoginSwiftUIView: AuthDelegate {
    mutating func didSigned(_ authManager: AuthManager, error: Error?) {
        if let error = error {
            print("SIGNED ERROR: \(error.localizedDescription)")
            updateUserLogin(false)
            return
        }
        
        userData.uid = authManager.userId
        userData.token = authManager.userToken
        userData.displayName = authManager.userDisplayName
        updateUserLogin(true)
    }
    
    func updateUserLogin(_ target: Bool) -> Void {
        if(userData.isLogin == target)
        {
            return
        }
        
        userData.isLogin.toggle()
    }
}
