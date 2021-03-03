//
//  ViewController.swift
//  AR Guitar
//

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController, ARSessionDelegate {
    
    private let humanBodyPoseRequest = VNDetectHumanBodyPoseRequest()
    
    private func imageFromFrame(_ buffer: ARFrame) -> CGImage? {
        let imageBuffer = buffer.capturedImage;

        // Create a Core Image context.
        let ciContext = CIContext(options: nil)

        // Create a Core Image image from the sample buffer.
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)

        // Generate a Core Graphics image from the Core Image image.
        guard let cgImage = ciContext.createCGImage(ciImage,
                                                    from: ciImage.extent) else {
            print("Unable to create an image from a frame.")
            return nil
        }

        return cgImage
    }

    /// Locates human body poses in an image.
    /// - Parameter frame: An image.
    /// - Returns: A `Pose` array if `VNDetectHumanBodyPoseRequest` succeeds
    /// and its `results` property isn't `nil`; otherwise `nil`.
    ///
    /// The method also sends the frame and any poses in it to the delegate.
    /// - Tag: findPosesInFrame
    private func findPosesInFrame(_ frame: CGImage) -> [Pose]? {
        // Create a request handler for the image.
        let visionRequestHandler = VNImageRequestHandler(cgImage: frame)

        // Use Vision to find human body poses in the frame.
        do { try visionRequestHandler.perform([humanBodyPoseRequest]) } catch {
            assertionFailure("Human Pose Request failed: \(error)")
        }

        let poses = Pose.fromObservations(humanBodyPoseRequest.results)

        // Send the frame and poses, if any, to the delegate on the main queue.
//        DispatchQueue.main.async {
//            self.delegate?.videoProcessingChain(self, didDetect: poses, in: frame)
//        }

        return poses
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let cgImage = imageFromFrame(frame) else {
            return;
        }
        
        guard let pose = findPosesInFrame(cgImage) else {
            return;
        }
        
        // TODO:
    }
    
//    @IBOutlet var arView: ARView!
//    
//    let headAnchor = AnchorEntity()
//    let hipAnchor = AnchorEntity()
//    let rightHandAnchor = AnchorEntity()
//    let leftHandAnchor = AnchorEntity()
//    
//    var headBox: Experience.HeadBox!
//    var hipBox: Experience.HipsBox!
//    var rightHandBox: Experience.RightHandBox!
//    var leftHandBox: Experience.LeftHandBox!
//    
//    var strummed = false
//    var label = MessageLabel()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // If you get a complaint about ARView not having a member 'session',
//        // build to an actual device – not a simulator.
//        arView.session.delegate = self
//        
//        headBox = try! Experience.loadHeadBox()
//        hipBox = try! Experience.loadHipsBox()
//        rightHandBox = try! Experience.loadRightHandBox()
//        leftHandBox = try! Experience.loadLeftHandBox()
//        
//        arView.scene.addAnchor(headAnchor)
//        arView.scene.addAnchor(hipAnchor)
//        arView.scene.addAnchor(rightHandAnchor)
//        arView.scene.addAnchor(leftHandAnchor)
//        
//        let configuration = ARBodyTrackingConfiguration()
//        arView.session.run(configuration)
//        
//        label = MessageLabel(frame: CGRect(x: 0, y: 0, width: 300, height: 100))
//        label.center = view.center
//        label.center.y += 200
//        label.textAlignment = .center
//        label.text = "Point the camera at someone \na few feet away"
//        label.textColor = .white
//        label.numberOfLines = 0
//        view.addSubview(label)
//    }
//    
//    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
//        for anchor in anchors {
//            guard let bodyAnchor = anchor as? ARBodyAnchor else { continue }
//            guard let headTransform = bodyAnchor.skeleton.modelTransform(for: .head) else { continue }
//            guard let hipTransform = bodyAnchor.skeleton.modelTransform(for: .root) else { continue }
//            guard let rightHandTransform = bodyAnchor.skeleton.modelTransform(for: .rightHand) else { continue }
//            guard let leftHandTransform = bodyAnchor.skeleton.modelTransform(for: .leftHand) else { continue }
//            
//            let headPosition = simd_make_float3(bodyAnchor.transform.columns.3) + simd_make_float3(headTransform.columns.3)
//            headAnchor.position = headPosition
//
//            let hipPosition = simd_make_float3(bodyAnchor.transform.columns.3) + simd_make_float3(hipTransform.columns.3)
//            hipAnchor.position = hipPosition
//            
//            let rightHandPosition = simd_make_float3(bodyAnchor.transform.columns.3) + simd_make_float3(rightHandTransform.columns.3)
//            rightHandAnchor.position = rightHandPosition
//            
//            let leftHandPosition = simd_make_float3(bodyAnchor.transform.columns.3) + simd_make_float3(leftHandTransform.columns.3)
//            leftHandAnchor.position = leftHandPosition
//            
//            if headBox.parent == nil {
//                headAnchor.addChild(headBox)
//                hipAnchor.addChild(hipBox)
//                rightHandAnchor.addChild(rightHandBox)
//                leftHandAnchor.addChild(leftHandBox)
//                
//            }
//            
//        }
//    }
}
