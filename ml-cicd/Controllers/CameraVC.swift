//
//  CameraVC.swift
//  ml-cicd
//
//  Created by Ascentspark on 09/09/20.
//  Copyright © 2020 Ascentspark. All rights reserved.
//

import UIKit
import AVKit
import NSFWDetector
import Vision

class CameraVC: UIViewController {

    private var subsequentPositiveDetections = 0

    @IBOutlet weak var visualEffectsView: UIVisualEffectView!
    @IBOutlet weak var nsfwLabel: UILabel!

    @IBOutlet weak var alarmView: UIVisualEffectView!
    @IBOutlet weak var emojiView: UIView!
    
    @IBOutlet weak var closeButton: UIButton!
    
    private var player: AVPlayer?
    
    deinit {
        player?.pause()
        player = nil
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.visualEffectsView.layer.cornerRadius = 10
        self.visualEffectsView.layer.masksToBounds = true
        
        self.alarmView.isHidden = true
        setupCaptureSession()
        closeButton.addTarget(self, action: #selector(closeButtonTask), for: .touchUpInside)
    }

    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        NSFWDetector.shared.check(cvPixelbuffer: pixelBuffer) { [weak self] result in
            guard let `self` = self else { return }
            if case let .success(nsfwConfidence: confidence) = result {
                DispatchQueue.main.async {
                    self.didDetectNSFW(confidence: confidence)
                }
            }
        }
    }
    
    private func didDetectNSFW(confidence: Float) {
        if confidence > 0.8 {
            self.subsequentPositiveDetections += 1
            
            guard self.subsequentPositiveDetections > 3 else {
                return
            }
            self.showAlarmView()
        }
        else {
            self.subsequentPositiveDetections = 0
            self.hideAlarmView()
        }
        self.nsfwLabel.text = String(format: "%.1f %% nude", confidence * 100.0)
    }
    
    private func showAlarmView() {
        guard self.alarmView.isHidden else {
            return
        }
        
        self.alarmView.isHidden = false
        self.alarmView.effect = nil
        self.emojiView.alpha = 0.0
        
        UIView.animate(withDuration: 0.3) {
            self.alarmView.effect = UIBlurEffect(style: .light)
            self.emojiView.alpha = 1.0
        }
        
        guard let path = Bundle.main.path(forResource: "Wilhelm_Scream.ogg", ofType: "mp3") else {
            return
        }
        self.player = AVPlayer(url: URL(fileURLWithPath: path))
        self.player?.play()
        self.player?.actionAtItemEnd = .pause
    }
    
    private func hideAlarmView() {
        guard  !self.alarmView.isHidden else {
            return
        }
        
        self.player?.pause()
        self.player = nil
        
        UIView.animate(withDuration: 0.3, animations: {
            self.alarmView.effect = nil
            self.emojiView.alpha = 0.0
        }) { finished in
            if finished {
                self.alarmView.isHidden = true
                self.subsequentPositiveDetections = 0
            }
            
        }
    }
    
    @objc func closeButtonTask(){
        self.dismiss(animated: true, completion: nil)
    }
}

extension CameraVC: AVCaptureVideoDataOutputSampleBufferDelegate {
    private var frontCamera: AVCaptureDevice? {
        return AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInMicrophone, .builtInDualCamera, .builtInTelephotoCamera, .builtInWideAngleCamera], mediaType: .video, position: .front).devices.first
    }
    private func setupCaptureSession() {
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        guard
            let frontCamera = self.frontCamera,
            let input = try? AVCaptureDeviceInput(device: frontCamera)
        else { return }
        
        captureSession.addInput(input)
        
        let capturePreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        capturePreviewLayer.videoGravity = .resizeAspectFill
        
        self.view.layer.insertSublayer(capturePreviewLayer, at: 0)
        capturePreviewLayer.frame = self.view.bounds
        
        let videoOutput = AVCaptureVideoDataOutput()
        
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer delegate"))
        videoOutput.recommendedVideoSettings(forVideoCodecType: .jpeg, assetWriterOutputFileType: .mp4)
        
        captureSession.addOutput(videoOutput)
        captureSession.sessionPreset = .high
        captureSession.startRunning()
    }
}
