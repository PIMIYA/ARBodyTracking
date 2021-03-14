import SwiftUI
import FirebaseUI

struct AuthViewController: UIViewControllerRepresentable {
    private var authUI: FUIAuth
    
    init(authUI: FUIAuth) {
        self.authUI = authUI
    }
    
    func makeUIViewController(context: Context) -> UINavigationController {
        return self.authUI.authViewController()
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
    }
    
    typealias UIViewControllerType = UINavigationController
}
