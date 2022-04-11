//
//  UIImage+Extension.swift
//  test-pytorch-ios
//
//  Created by Armen Hakobyan on 18.10.21.
//

import UIKit
enum NormalizedType {
    case rgb
    case gray
}

extension UIImage {
    func resized(to newSize: CGSize, scale: CGFloat = 1) -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = scale
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        let image = renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
        return image
    }
    
    func padd() -> UIImage? {
        guard let cgImage = self.cgImage else {
            return nil
        }
        let w = cgImage.width
        let h = cgImage.height
        
        let contextSize = max(w, h)
        UIGraphicsBeginImageContext(CGSize(width: contextSize, height: contextSize))
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.black.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: contextSize, height: contextSize))
        if w > h {
            self.draw(in: CGRect(x: 0, y: (contextSize - h)/2, width: w, height: h))
        } else if w < h {
            self.draw(in: CGRect(x: (contextSize - w)/2, y: 0, width: w, height: h))
        } else {
            self.draw(in: CGRect(x: 0, y: 0, width: w, height: h))
        }
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result
    }
    
    func drawRectangle(rectangle: CGRect) -> UIImage? {
        let image = self
        let renderer = UIGraphicsImageRenderer(size: image.size)
        let newImage = renderer.image { ctx in
            ctx.cgContext.setFillColor(UIColor.clear.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.green.cgColor)
            ctx.cgContext.setLineWidth(4)

            ctx.cgContext.addRect(rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
            self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height), blendMode: .color, alpha: 1.0)
        }

        return newImage
    }

    func drawLandmark(origin: [Int]) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: self.size)
        let newImage = renderer.image { ctx in
            ctx.cgContext.setFillColor(UIColor.clear.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.green.cgColor)
            ctx.cgContext.setLineWidth(8)

            ctx.cgContext.addRect(CGRect(x: origin[0], y: origin[1], width: 1, height: 1))
            ctx.cgContext.drawPath(using: .fillStroke)

            self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height), blendMode: .luminosity, alpha: 1.0)
        }

        return newImage
    }
            
    func cropImage(rect: CGRect, scale: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: rect.size.width / scale, height: rect.size.height / scale), true, 0.0)
        self.draw(at: CGPoint(x: -rect.origin.x / scale, y: -rect.origin.y / scale))
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return croppedImage
    }
    
    func normalized(type: NormalizedType) -> [Float32]? {
        guard let cgImage = self.cgImage else {
            return nil
        }
        
        var colorSpace: CGColorSpace?
        var bitmapInfo: CGBitmapInfo?
        var bytesPerPixel = 1

        
        switch type {
        case .rgb:
        bytesPerPixel*=4
        colorSpace = CGColorSpaceCreateDeviceRGB()
        bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

        case .gray:
        colorSpace = CGColorSpaceCreateDeviceGray()
        bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        }
        
        let w = cgImage.width
        let h = cgImage.height
        let bytesPerRow = bytesPerPixel * w
        let bitsPerComponent = 8
        var rawBytes: [UInt8] = [UInt8](repeating: 0, count: w * h * bytesPerPixel)
        rawBytes.withUnsafeMutableBytes { ptr in
            if let cgImage = self.cgImage,
                let context = CGContext(data: ptr.baseAddress,
                                        width: w,
                                        height: h,
                                        bitsPerComponent: bitsPerComponent,
                                        bytesPerRow: bytesPerRow,
                                        space: colorSpace!,
                                        bitmapInfo: bitmapInfo!.rawValue) {
                let rect = CGRect(x: 0, y: 0, width: w, height: h)
                context.draw(cgImage, in: rect)
                if let makeImg = context.makeImage() {
                    let imageRef = makeImg
                    let newImage = UIImage(cgImage: imageRef)
                    print( newImage)
                }
            }
        }
        
        switch type {
        case .rgb:
            var normalizedBuffer: [Float32] = [Float32](repeating: 0, count: w * h * 3)
            for i in 0 ..< w * h {
                normalizedBuffer[i] = Float32(rawBytes[i * 4 + 0])/127.5 - 1.0
                normalizedBuffer[w * h + i] = Float32(rawBytes[i * 4 + 1])/127.5 - 1.0
                normalizedBuffer[w * h * 2 + i] = Float32(rawBytes[i * 4 + 2])/127.5 - 1.0
            }
            return normalizedBuffer
        case .gray:
            var normalizedBuffer: [Float32] = [Float32](repeating: 0, count: w * h)
            let _rawBytes = rawBytes.map { Float32($0)/255.0 }

            let minByte = Float32(_rawBytes.min() ?? 0)
            let maxByte = Float32(_rawBytes.max() ?? 0)
            for i in 0 ..< w * h {
                let rawByte = Float32(_rawBytes[i])
                let byteRange = (rawByte - minByte) / (maxByte - minByte)

                normalizedBuffer[i] = Float32(2 * byteRange - 1)
            }

            return normalizedBuffer
        }
    }
}

