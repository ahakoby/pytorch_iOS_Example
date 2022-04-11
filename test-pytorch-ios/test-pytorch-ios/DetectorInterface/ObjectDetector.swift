//
//  ObjectDetector.swift
//  test-pytorch-ios
//
//  Created by Armen Hakobyan on 18.10.21.
//

import UIKit

class ObjectDetector {
    
    lazy var landmarksDetection: InferenceModule = {
        if let filePath = Bundle.main.path(forResource: "landmarks_detection_model", ofType: "ptl"),
            let module = InferenceModule(fileAtPath: filePath) {
            return module
        } else {
            fatalError("Failed to load model!")
        }
    }()

    lazy var faceDetection: InferenceModule = {
        if let filePath = Bundle.main.path(forResource: "face_detection_model", ofType: "ptl"),
            let module = InferenceModule(fileAtPath: filePath) {
            return module
        } else {
            fatalError("Failed to load model!")
        }
    }()
}
