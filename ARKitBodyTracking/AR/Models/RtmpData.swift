//
//  RtmpData.swift
//  ARDemo
//
//  Created by Mars on 2021-03-19.
//  Copyright © 2021 Tony Morales. All rights reserved.
//

import SwiftUI

class RtmpData: NSObject, ObservableObject {
    @Published var videoId: String = ""
    @Published var streamPath: String = ""
    @Published var streamKey: String = ""
}
