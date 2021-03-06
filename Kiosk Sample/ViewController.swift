//
//  ViewController.swift
//  Kiosk Sample
//
//  Created by Jakub Dolejs on 28/04/2020.
//  Copyright © 2020 Applied Recognition. All rights reserved.
//

import UIKit
import AVFoundation
import VerIDCore
import VerIDUI

/// View controller that displays a camera preview
public class ViewController: CameraViewController, VerIDFactoryDelegate, VerIDSessionDelegate, VerIDSessionViewDelegate {
    
    
    private var verid: VerID?
    @objc private dynamic var isFacePresent = false
    private var faceObservation: NSKeyValueObservation?
    private var veridSessionViewController: UIViewController?
    @IBOutlet var label: UILabel!
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        let veridFactory = VerIDFactory()
        veridFactory.delegate = self
        veridFactory.createVerID()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.label.text = "Loading Ver-ID"
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.faceObservation?.invalidate()
        self.faceObservation = nil
    }
    
    // MARK: - Ver-ID session delegate
    
    public func session(_ session: VerIDSession, didFinishWithResult result: VerIDSessionResult) {
        self.label.text = result.error == nil ? "Session succeeded" : "Session failed"
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            self.startAbsenceDetection()
        }
    }
    
    public func sessionWasCanceled(_ session: VerIDSession) {
        self.label.text = "Session cancelled"
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            self.startAbsenceDetection()
        }
    }
    
    // MARK: - Ver-ID session view delegate
    
    public func presentVerIDViewController(_ viewController: UIViewController & VerIDViewControllerProtocol) {
        self.replaceSessionViewController(with: viewController)
    }
    
    public func presentResultViewController(_ viewController: UIViewController & ResultViewControllerProtocol) {
        self.replaceSessionViewController(with: viewController)
    }
    
    public func presentTipsViewController(_ viewController: UIViewController & TipsViewControllerProtocol) {
        self.replaceSessionViewController(with: viewController)
    }
    
    public func closeViews(callback: @escaping () -> Void) {
        self.removeSessionViewController()
        callback()
    }
    
    // MARK: - Ver-ID view controllers
    
    func replaceSessionViewController(with viewController: UIViewController) {
        self.removeSessionViewController()
        self.addSessionViewController(viewController)
    }
    
    func addSessionViewController(_ sessionViewController: UIViewController) {
        addChild(sessionViewController)
        sessionViewController.view.frame = self.view.frame
        self.view.addSubview(sessionViewController.view)
        sessionViewController.didMove(toParent: self)
        self.veridSessionViewController = sessionViewController
    }
    
    func removeSessionViewController() {
        guard let child = self.veridSessionViewController else {
            return
        }
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
        self.veridSessionViewController = nil
    }
    
    // MARK: - Ver-ID view controllers
    
    func startPresenceDetection() {
        self.label.text = "Step in front of the camera"
        self.faceObservation = self.observe(\.self.isFacePresent, options: [.initial,.new]) { _, value in
            if let isPresent = value.newValue, isPresent, let verid = self.verid {
                self.faceObservation?.invalidate()
                self.faceObservation = nil
                DispatchQueue.main.async {
                    let settings = LivenessDetectionSessionSettings()
                    let session = VerIDSession(environment: verid, settings: settings)
                    session.viewDelegate = self
                    session.delegate = self
                    session.start()
                }
            }
        }
    }
    
    func startAbsenceDetection() {
        self.label.text = "Please step away from the camera"
        self.faceObservation = self.observe(\.self.isFacePresent, options: [.initial,.new]) { _, value in
            if let isPresent = value.newValue, !isPresent {
                self.faceObservation?.invalidate()
                self.faceObservation = nil
                DispatchQueue.main.async {
                    self.startPresenceDetection()
                }
            }
        }
    }
    
    // MARK: - Ver-ID factory delegate
    
    public func veridFactory(_ factory: VerIDFactory, didCreateVerID instance: VerID) {
        self.verid = instance        
        self.startPresenceDetection()
    }
    
    public func veridFactory(_ factory: VerIDFactory, didFailWithError error: Error) {
        let alert = UIAlertController(title: "Failed to load Ver-ID", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    // MARK: - AV capture session
    
    public override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let verid = self.verid else {
            return
        }
        let image = VerIDImage(sampleBuffer: sampleBuffer, orientation: self.imageOrientation)
        guard let faces = try? verid.faceDetection.detectFacesInImage(image, limit: 1, options: 0) else {
            return
        }
        self.isFacePresent = !faces.isEmpty
    }
}
