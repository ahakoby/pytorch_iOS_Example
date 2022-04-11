//
//  InferenceModule.h
//  test-pytorch-ios
//
//  Created by Armen Hakobyan on 18.10.21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface InferenceModule : NSObject

- (nullable instancetype)initWithFileAtPath:(NSString*)filePath
    NS_SWIFT_NAME(init(fileAtPath:))NS_DESIGNATED_INITIALIZER;

- (nullable NSArray<NSArray<NSNumber*>*>*)detectFace:(void*)imageBuffer
                                       originalImage:(CGSize)size NS_SWIFT_NAME(detectFace(image:originalImage:));

- (nullable NSArray<NSArray<NSNumber*>*>*)detectLandmarks:(void*)imageBuffer
                                                  faceBox:(NSArray*)input  NS_SWIFT_NAME(detectLandmarks(image:faceBox:));

@end

NS_ASSUME_NONNULL_END
