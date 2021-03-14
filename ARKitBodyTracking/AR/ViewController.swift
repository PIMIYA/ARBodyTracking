import UIKit
import RealityKit
import ARKit
import CocoaAsyncSocket

class ViewController: UIViewController, ARSessionDelegate {
    @IBOutlet var arView: ARView!
    
    private var currentBuffer: CVPixelBuffer?
    private var humanBodyPoseRequest = VNDetectHumanBodyPoseRequest()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arView.session.delegate = self
    }
    
    private func findPosesInFrame() -> [Pose]? {
        let orientation = CGImagePropertyOrientation(UIDevice.current.orientation)
        let visionRequestHandler = VNImageRequestHandler(cvPixelBuffer: currentBuffer!, orientation: orientation)
        
        // Use Vision to find human body poses in the frame.
        visionQueue.async {
            do {
                defer { self.currentBuffer = nil }
                try visionRequestHandler.perform([self.humanBodyPoseRequest])
            } catch {
                assertionFailure("Human Pose Request failed: \(error)")
            }
        }
        
        return Pose.fromObservations(humanBodyPoseRequest.results)
    }
    
    private let visionQueue = DispatchQueue(label: "com.chenghsienyu.ARDemo-vision")
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard currentBuffer == nil, case .normal = frame.camera.trackingState else {
            return
        }
        
        self.currentBuffer = frame.capturedImage
        
        imageProcessing()
    }
    
    private func imageProcessing() {
        guard let poses = findPosesInFrame() else {
            return;
        }
        
        poses.forEach { pose in
            guard let p = pose.getJointPoint(Pose.JointName.neck) else {
                return
            }
            
            print(p)
        }

        for poseObj in poses {
            guard poseObj.multiArray != nil else {
                return
            }
            print(poseObj)
        }
        
            
        print(poses.count)

    }
    
        
}
