# pytorch_iOS_Example 

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

Using from react-native
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(RCTModule, NSObject)

RCT_EXTERN_METHOD(getLandmarkedImage:(NSString *)inputImagePath success:(@escaping RCTPromiseResolveBlock *)callback)

@end
