import UIKit
import RealityKit
import ARKit
import CocoaAsyncSocket

class ViewController: UIViewController, ARSessionDelegate {
    @IBOutlet var arView: ARView!
    
    private var currentBuffer: CVPixelBuffer?
    private var humanBodyPoseRequest = VNDetectHumanBodyPoseRequest()
    
    private var liveButton: UIButton!
    private var isLive: Bool = false
    private var rtmpData: RtmpData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arView.session.delegate = self
        // UserData.sharedInstance.dump()
        
        let btnRect = CGRect(x: 20, y: 20, width: 120, height: 35)
        liveButton = UIButton(frame: btnRect)
        liveButton.setTitleColor(UIColor.red, for: .normal)
        liveButton.setTitle("START", for: .normal)
        liveButton.addTarget(self, action: #selector(self.toggleLive), for: .touchUpInside)
        arView.addSubview(liveButton)
    }
    
    @objc func toggleLive(sender: UIButton!) {
        if isLive {
            stopLive()
        } else {
            startLive()
        }
        
        isLive.toggle()
        liveButton.setTitle((isLive ? "STOP" : "START"), for: .normal)
    }
    
    private func stopLive() {
        if self.rtmpData == nil {
            return
        }
        
        let token = UserData.shared.token
        let videoId = self.rtmpData.videoId
        FbLiveService.shared.endFbLive(token: token, videoId: videoId)
    }
    
    private func startLive() {
        let token = UserData.shared.token
        let uid = UserData.shared.uid
        FbLiveService.shared.publish(token: token, uid: uid, callback: liveStarted(_:))
    }
    
    private func liveStarted(_ rtmpData: RtmpData?) {
        self.rtmpData = rtmpData
        print(self.rtmpData.videoId)
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
            
            // print(p)
        }
        
        for poseObj in poses {
            guard poseObj.multiArray != nil else {
                return
            }
            // print(poseObj)
        }
        
        // print(poses.count)
    }
    
    
}
