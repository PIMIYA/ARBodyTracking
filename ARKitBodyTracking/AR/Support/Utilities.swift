//
//  Utilities.swift
//  ARDemo
//
//  Created by Mars on 2021-03-06.
//  Copyright © 2021 Tony Morales. All rights reserved.
//

import Foundation
import ARKit

extension CGImagePropertyOrientation {
    init(_ deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portraitUpsideDown: self = .left
        case .landscapeLeft: self = .up
        case .landscapeRight: self = .down
        default: self = .right
        }
    }
}
