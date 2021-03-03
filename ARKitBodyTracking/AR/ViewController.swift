//
//  ViewController.swift
//  AR Guitar
//

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController, ARSessionDelegate {
    
    @IBOutlet var arView: ARView!
    
    let headAnchor = AnchorEntity()
    let hipAnchor = AnchorEntity()
    let rightHandAnchor = AnchorEntity()
    let leftHandAnchor = AnchorEntity()
    
    var headBox: Experience.HeadBox!
    var hipBox: Experience.HipsBox!
    var rightHandBox: Experience.RightHandBox!
    var leftHandBox: Experience.LeftHandBox!
    
    var strummed = false
    var label = MessageLabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If you get a complaint about ARView not having a member 'session',
        // build to an actual device – not a simulator.
        arView.session.delegate = self
        
        headBox = try! Experience.loadHeadBox()
        hipBox = try! Experience.loadHipsBox()
        rightHandBox = try! Experience.loadRightHandBox()
        leftHandBox = try! Experience.loadLeftHandBox()
        
        arView.scene.addAnchor(headAnchor)
        arView.scene.addAnchor(hipAnchor)
        arView.scene.addAnchor(rightHandAnchor)
        arView.scene.addAnchor(leftHandAnchor)
        
        let configuration = ARBodyTrackingConfiguration()
        arView.session.run(configuration)
        
        label = MessageLabel(frame: CGRect(x: 0, y: 0, width: 300, height: 100))
        label.center = view.center
        label.center.y += 200
        label.textAlignment = .center
        label.text = "Point the camera at someone \na few feet away"
        label.textColor = .white
        label.numberOfLines = 0
        view.addSubview(label)
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let bodyAnchor = anchor as? ARBodyAnchor else { continue }
            guard let headTransform = bodyAnchor.skeleton.modelTransform(for: .head) else { continue }
            guard let hipTransform = bodyAnchor.skeleton.modelTransform(for: .root) else { continue }
            guard let rightHandTransform = bodyAnchor.skeleton.modelTransform(for: .rightHand) else { continue }
            guard let leftHandTransform = bodyAnchor.skeleton.modelTransform(for: .leftHand) else { continue }
            
            let headPosition = simd_make_float3(bodyAnchor.transform.columns.3) + simd_make_float3(headTransform.columns.3)
            headAnchor.position = headPosition

            let hipPosition = simd_make_float3(bodyAnchor.transform.columns.3) + simd_make_float3(hipTransform.columns.3)
            hipAnchor.position = hipPosition
            
            let rightHandPosition = simd_make_float3(bodyAnchor.transform.columns.3) + simd_make_float3(rightHandTransform.columns.3)
            rightHandAnchor.position = rightHandPosition
            
            let leftHandPosition = simd_make_float3(bodyAnchor.transform.columns.3) + simd_make_float3(leftHandTransform.columns.3)
            leftHandAnchor.position = leftHandPosition
            
            if headBox.parent == nil {
                headAnchor.addChild(headBox)
                hipAnchor.addChild(hipBox)
                rightHandAnchor.addChild(rightHandBox)
                leftHandAnchor.addChild(leftHandBox)
                
            }
            
        }
    }
}
