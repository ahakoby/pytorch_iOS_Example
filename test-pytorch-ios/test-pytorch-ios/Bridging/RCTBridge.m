//
//  RCTBridge.m
//  test-pytorch-ios
//
//  Created by Armen Hakobyan on 20.10.21.
//

#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(RCTModule, NSObject)

RCT_EXTERN_METHOD(getLandmarkedImage:(NSString *)inputImagePath success:(@escaping RCTPromiseResolveBlock *)callback)

@end
