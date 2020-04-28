//
//  CameraPreviewView.swift
//  Kiosk Sample
//
//  Created by Jakub Dolejs on 28/04/2020.
//  Copyright © 2020 Applied Recognition. All rights reserved.
//

import UIKit
import AVFoundation

/// View that shows camera preview
class CameraPreviewView: UIView {
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return self.layer as! AVCaptureVideoPreviewLayer
    }
    
    var session: AVCaptureSession? {
        get {
            return self.videoPreviewLayer.session
        }
        set {
            self.videoPreviewLayer.session = newValue
        }
    }
    
    // MARK: UIView
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}

