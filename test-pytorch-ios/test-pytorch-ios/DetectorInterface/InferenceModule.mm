//
//  InferenceModule.m
//  test-pytorch-ios
//
//  Created by Armen Hakobyan on 18.10.21.
//

#import "InferenceModule.h"
//#import <Libtorch-Lite/Libtorch-Lite.h>
#import <Libtorch/Libtorch.h>

// 256x256 is the default image size used in the face_detection_model.ptl
const int input_width_face = 256;
const int input_height_face = 256;

// 128x128 is the default image size used in the face_detection_model.ptl
const int input_width_landmark = 128;
const int input_height_landmark = 128;

@implementation InferenceModule {
    @protected torch::jit::Module _impl;
}

- (nullable instancetype)initWithFileAtPath:(NSString*)filePath {
    self = [super init];
    if (self) {
        try {
            _impl = torch::jit::load(filePath.UTF8String);
        } catch (const std::exception& exception) {
            NSLog(@"%s", exception.what());
            return nil;
        }
    }
    return self;
}

- (NSArray<NSArray<NSNumber*>*>*)detectFace:(void*)imageBuffer originalImage:(CGSize)size {
    try {
        at::Tensor tensor = torch::from_blob(imageBuffer, { 1, 3, input_height_face, input_width_face }, at::kFloat);
        at::Tensor tensorD = torch::zeros({1,2});
        tensorD[0][0] = size.height;
        tensorD[0][1] = size.width;
        
        auto outputTensor = _impl.forward({tensor, tensorD}).toTensor();
        
        NSMutableArray* results = [[NSMutableArray alloc] init];

//        auto secondDimensionTensor = outputTensor[0][0];
//        print(secondDimensionTensor);
//
//
//        float* secondDimensionFloatBuffer = secondDimensionTensor.data_ptr<float>();
//        if (!secondDimensionFloatBuffer) {
//            return nil;
//        }
//
//        NSMutableArray* firstResult = [[NSMutableArray alloc] init];
//        for (int i = 0; i < 4; i++) {
//          [firstResult addObject:@(secondDimensionFloatBuffer[i])];
//        }
//
//        [results addObject:firstResult];

        auto thirdDimensionTensor = outputTensor[0][1];

        float* thirdDimensionFloatBuffer = thirdDimensionTensor.data_ptr<float>();
        if (!thirdDimensionFloatBuffer) {
            return nil;
        }

        NSMutableArray* secondResult = [[NSMutableArray alloc] init];
        for (int i = 0; i < 4; i++) {
          [secondResult addObject:@(thirdDimensionFloatBuffer[i])];
        }
        
        [results addObject:secondResult];
        
        return [results copy];
  
        return nil;
    } catch (const std::exception& exception) {        
        NSLog(@"%s", exception.what());
    }
    return nil;
}

- (nullable NSArray<NSArray<NSNumber *> *> *)detectLandmarks:(void *)imageBuffer
                                                     faceBox:(NSArray<NSNumber *> *)input {
    
    at::Tensor tensor = torch::from_blob(imageBuffer, { 1, 1, input_height_landmark, input_width_landmark }, at::kFloat);
    at::Tensor tensorD = torch::tensor({{input[0].floatValue, input[1].floatValue, input[2].floatValue, input[3].floatValue}});
    
    auto outputTensor = _impl.forward({tensor, tensorD}).toTensor();
    
    auto thirdDimensionTensor = outputTensor[0];

    float* thirdDimensionFloatBuffer = outputTensor.data_ptr<float>();
    if (!thirdDimensionFloatBuffer) {
        return nil;
    }

    NSMutableArray* result = [[NSMutableArray alloc] init];
    for (int i = 0; i < thirdDimensionTensor.numel()/2; i++) {
        auto tensor = thirdDimensionTensor[i];

        float* tensorBuffer = tensor.data_ptr<float>();
        if (tensorBuffer != nil) {
            NSMutableArray* coordinates = [[NSMutableArray alloc] init];
            for (int j = 0; j < 2; j++) {
                [coordinates addObject:@(tensorBuffer[j])];
            }

            [result addObject:coordinates];
        }
    }

    return result;
}

@end
