//
//  FbLiveService.swift
//  ARDemo
//
//  Created by Mars on 2021-03-19.
//  Copyright © 2021 Tony Morales. All rights reserved.
//

import FBSDKShareKit
import HaishinKit
import Network

class FbLiveService: NSObject {
    public var sharedInstance: FbLiveService = FbLiveService()
    
    private let rtmpConnection = RTMPConnection()
    private var rtmpStream: RTMPStream!
    
    override init()
    {
        self.rtmpStream = RTMPStream(connection: rtmpConnection)
    }
    
    func publish(token: String, uid: String, callback: @escaping ((RtmpData)->Void)) -> Void {
        let graphPath = "/\(uid)/live_videos"
        let parameters = [ "status": "LIVE_NOW",
                           "title": "AR SHOW",
                           "description": "",
                           "stop_on_delete_stream": true
        ] as [String : Any]
        print("[publishFbLive]::\(token), \(uid), \(graphPath), \(parameters)")
        let graphRequest = GraphRequest.init(graphPath: graphPath, parameters: parameters, tokenString: token,
                                             version: Settings.defaultGraphAPIVersion, httpMethod: HTTPMethod.post)
        let graphRequestConnection = GraphRequestConnection()
        graphRequestConnection.add(graphRequest) { (connection, result, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let fbResult = result as? Dictionary<String, Any>,
                  let videoId = fbResult["id"] as? String,
                  let resultStreamUrl = fbResult["stream_url"] as? String,
                  let resultSecureStreamUrl = fbResult["secure_stream_url"] as? String
            else{
                return
            }
            print("fb graph result: \(videoId), \(resultStreamUrl), \(resultSecureStreamUrl)")
            
            let streamPath = "rtmps://live-api-s.facebook.com:443/rtmp/"
            let streamKey = resultSecureStreamUrl.replacingOccurrences(of: streamPath, with: "")
            
            //            self.rtmpInfo.videoId = videoId
            //            self.rtmpInfo.streamPath = streamPath
            //            self.rtmpInfo.streamKey = streamKey
            
            print("================ \(streamKey)")
            self.rtmpConnection.requireNetworkFramework = true
            let rtmpConnParams = NWParameters.tls;
            self.rtmpConnection.parameters = rtmpConnParams;
            
            if self.rtmpStream == nil {
                self.rtmpStream = RTMPStream(connection: self.rtmpConnection)
            }
            
            guard let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation else {
                #if DEBUG
                fatalError("Could not obtain UIInterfaceOrientation from a valid windowScene")
                #else
                return nil
                #endif
            }
            if let avOrientation = DeviceUtil.videoOrientation(by: orientation) {
                self.rtmpStream.orientation = avOrientation
            }
            //            rtmpStream.captureSettings = [
            //                .fps: 30,
            //                .sessionPreset: AVCaptureSession.Preset.hd1280x720,
            //                .continuousAutofocus: true,
            //                .continuousExposure: true
            //            ]
            //            rtmpStream.videoSettings = [
            //                .width: 720,
            //                .height: 1280,
            //                .bitrate: 160000
            //            ]
            //            rtmpStream.audioSettings = [
            //                .muted: false, // mute audio
            //                .sampleRate: 48000,
            //                .bitrate: 256000
            //            ]
            // "0" means the same of input
            self.rtmpStream.recorderSettings = [
                AVMediaType.audio: [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 0,
                    AVNumberOfChannelsKey: 0,
                    // AVEncoderBitRateKey: 128000,
                ],
                AVMediaType.video: [
                    AVVideoCodecKey: AVVideoCodecType.h264,
                    AVVideoHeightKey: 0,
                    AVVideoWidthKey: 0,
                    /*
                     AVVideoCompressionPropertiesKey: [
                     AVVideoMaxKeyFrameIntervalDurationKey: 2,
                     AVVideoProfileLevelKey: AVVideoProfileLevelH264Baseline30,
                     AVVideoAverageBitRateKey: 512000
                     ]
                     */
                ],
            ]
            
            self.rtmpStream.attachScreen(ScreenCaptureSession(shared: UIApplication.shared), useScreenSize: true)
            self.rtmpStream.attachAudio(AVCaptureDevice.default(for: AVMediaType.audio),
                                        automaticallyConfiguresApplicationAudioSession: false) { error in
                print(error.localizedDescription)
                return
            }
            //            rtmpStream.attachCamera(DeviceUtil.device(withPosition: .back)) { error in
            //                print(error.localizedDescription)
            //                return
            //            }
            
            self.rtmpConnection.connect(streamPath)
            self.rtmpStream.publish(streamKey)
            
            print("rtmpStream.publish")
            let rtmpData = RtmpData()
            rtmpData.videoId = videoId
            rtmpData.streamKey = streamKey
            rtmpData.streamPath = streamPath
            callback(rtmpData)
        }
        
        print("[publishFbLive]:: graphRequestConnection.start")
        graphRequestConnection.start()
    }
    
    func requestEndFbLive(token: String, videoId: String, callback: @escaping () -> Void) -> Void {
        print("start requestEndFbLive")
        let graphPath = "/\(videoId)"
        let parameters = [ "title": "AR showing",
                           "description": "ar",
                           "end_live_video": true
        ] as [String : Any]
        
        print("[requestEndFbLive]:: \(graphPath), \(parameters), \(token)")
        let graphRequest = GraphRequest.init(graphPath: graphPath, parameters: parameters, tokenString: token,
                                             version: Settings.defaultGraphAPIVersion, httpMethod: HTTPMethod.post)
        let graphRequestConnection = GraphRequestConnection()
        graphRequestConnection.add(graphRequest, completionHandler: { (connection, result, error) in
            if let error = error {
                print("requestEndFbLive error");
                print(error.localizedDescription)
                callback()
                return
            }
            
            print("end requestEndFbLive")
            callback()
        })
        
        print("[requestEndFbLive]:: graphRequestConnection.start")
        graphRequestConnection.start()
    }
    
    func endFbLive(token: String, videoId: String) -> Void {
        print("start endFbLive")
        requestEndFbLive(token: token,
                         videoId: videoId,
                         callback: {() in
                            self.rtmpConnection.close()
                            self.rtmpStream.close()
                            self.rtmpStream.dispose()
                            print("end endFbLive")
                         })
    }
}
