//
//  UIViewWrapper.swift
//  ARDemo
//
//  Created by Mars on 2021-03-13.
//  Copyright © 2021 ARDemo. All rights reserved.
//
// 讓 SwiftUI 可以呼叫顯示 UIViewController

import SwiftUI
import UIKit

struct UIViewWrapper: UIViewControllerRepresentable {
    let storyboard: String
    let viewController: String
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<UIViewWrapper>) -> ViewController {
        
        //Load the storyboard
        let loadedStoryboard = UIStoryboard(name: storyboard, bundle: nil)
        
        //Load the ViewController
        return loadedStoryboard.instantiateViewController(withIdentifier: viewController) as! ViewController
        
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: UIViewControllerRepresentableContext<UIViewWrapper>) {
    }
}
