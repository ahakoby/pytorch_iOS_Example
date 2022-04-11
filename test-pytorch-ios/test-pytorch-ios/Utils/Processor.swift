//
//  Processor.swift
//  test-pytorch-ios
//
//  Created by Armen Hakobyan on 18.10.21.
//

import UIKit

struct Prediction {
  let rect: CGRect
}

class Processor : NSObject {
    static let inferencer = ObjectDetector()

    // model input image size
    static let inputWidthForFace = 256
    static let inputHeightForFace = 256
    static let inputWidthForFaceLandmarks = 128
    static let inputHeightForFaceLandmarks = 128
    
    static func detectFaceLandmarks(img: UIImage,
                                    landmarkedImageCompletionHandler: ((UIImage) -> Swift.Void)? = nil,
                                    landmarksCompletionHandler: (([[Any]]) -> Swift.Void)? = nil) {
        var image = img
        let resizedImage = img.padd()!.resized(to: CGSize(width: inputWidthForFace, height: inputHeightForFace))

        guard var pixelBuffer = resizedImage.normalized(type: .rgb) else {
            debugPrint("ERROR normalized(type: .rgb): Something went wrong while converting the image to a pixel buffer with three channel!!!")
            return
        }

        DispatchQueue.global().async {
            guard let outputs = inferencer.faceDetection.detectFace(image: &pixelBuffer, originalImage: image.size) else {
                debugPrint("ERROR: Face detection faild")
                return
            }

            let nmsPredictions = Processor.outputsToNMSPredictions(outputs: outputs)

            DispatchQueue.main.async {
                nmsPredictions.forEach { prediction in
                    if let img = image.drawRectangle(rectangle: prediction.rect) {
                        image = img
                    }
                }
                
                landmarkedImageCompletionHandler?(image)
            
                guard let prediction = nmsPredictions.last,
                      let cropedImage = image.cropImage(rect: prediction.rect, scale: 1)
                else {
                    debugPrint("ERROR: Image cropping faild (cropImage(toRect:))")
                    return }

                let resizedImage = cropedImage.resized(to: CGSize(width: inputWidthForFaceLandmarks, height: inputHeightForFaceLandmarks))

                guard var grayScaledPixelBuffer = resizedImage.normalized(type: .gray) else {
                    debugPrint("ERROR normalized(type: .gray): Something went wrong while converting the image to a pixel buffer with single channel!!! normalized(type: .rgb)")
                    return
                }

                DispatchQueue.global().async {
                    guard let landmarksOutput = self.inferencer.landmarksDetection.detectLandmarks(image: &grayScaledPixelBuffer, faceBox: outputs.last!) else {
                        debugPrint("ERROR: Face landmarks detection failed")
                        return }
                    
                    landmarksCompletionHandler?(landmarksOutput)
                    
                    DispatchQueue.main.async {

                        landmarksOutput.forEach { origin in
                            if let img = image.drawLandmark(origin: [origin[0].intValue, origin[1].intValue]) {
                                image = img
                            }
                        }
                        landmarkedImageCompletionHandler?(image)

                    }
                }
            }
        }
    }
    
    static func outputsToNMSPredictions(outputs: [[NSNumber]]) -> [Prediction] {
        var predictions = [Prediction]()
        outputs.forEach { output in
            
            let x = output[0].floatValue
            let y = output[1].floatValue
            let w = output[2].floatValue - output[0].floatValue
            let h = output[3].floatValue - output[1].floatValue
            if x != 0, y != 0, w != 0, h != 0 {
                let rect = CGRect(x: CGFloat(x), y: CGFloat(y), width: CGFloat(w), height: CGFloat(h))
            
                let containedPrediction = predictions.contains { pre in
                    pre.rect.equalTo(rect)
                }
                            
                if containedPrediction == false {
                    let prediction = Prediction(rect: rect)
                    predictions.append(prediction)
                }
            }            
        }

        return predictions
    }
}
