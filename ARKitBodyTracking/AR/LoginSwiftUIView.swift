import SwiftUI

struct LoginSwiftUIView: View {
    @State var isLogin = false
    
    private let authManager = AuthManager()
    
    init() {
        authManager.delegate = self
    }
    
    var body: some View {
        VStack {
            if isUserLogin() {
                Text("Is Logined")
            } else {
                Button(action: {self.isLogin = true}) {
                    Text("LOGIN")
                        .padding()
                        .background(Color.white)
                }
            }
        }.sheet(isPresented: self.$isLogin) {
            AuthViewController(authUI: self.authManager.authUI)
        }
        //        .fullScreenCover(isPresented: $isLogin) {
        //            UIViewWrapper(storyboard: "Storyboard", viewController: "arVC")
        //        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

extension LoginSwiftUIView: AuthDelegate {
    func didSigned(_ authManager: AuthManager, error: Error?) {
        if let error = error {
            print("SIGNED ERROR: \(error.localizedDescription)")
            return
        }
        
        print("\(authManager.userDisplayName)")
        
//        self.userInfo.userName = "\(system.userDisplayName) is signed";
//        print("\(self.userInfo.userName) == \(system.userDisplayName)")
    }
    
    func isUserLogin() -> Bool {
        return false
    }
}
