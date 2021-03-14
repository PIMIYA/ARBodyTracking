//  Let SwiftUI using in Storyboard

import SwiftUI

class HostingController: UIHostingController<AnyView> {

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: AnyView(EmptyView()))
    }
}
