//
//  UserData.swift
//  ARDemo
//
//  Created by Mars on 2021-03-19.
//  Copyright © 2021 Tony Morales. All rights reserved.
//

import SwiftUI

class UserData: ObservableObject {
    public static let sharedInstance: UserData = UserData()
    
    @Published var token: String = ""
    @Published var uid: String = ""
    @Published var displayName: String = ""
    @Published var isLogin: Bool = false
    
    public func dump() -> Void {
        print("Token: \(token)\nUid: \(uid)\nName: \(displayName)\nLogin: \(isLogin)")
    }
}
