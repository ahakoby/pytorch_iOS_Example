//
//  RCTModule.swift
//  test-pytorch-ios
//
//  Created by Armen Hakobyan on 20.10.21.
//

import UIKit
import Foundation
import React

@objc(RCTModule)
class RCTModule: NSObject {
    
    @objc func getLandmarkedImage(inputImagePath: String, successCallback: @escaping RCTPromiseResolveBlock) {
        guard let image = UIImage(contentsOfFile: inputImagePath) else {return}
        Processor.detectFaceLandmarks(img: image, landmarkedImageCompletionHandler: nil) { output in
            successCallback(output)
        }

    }
}
