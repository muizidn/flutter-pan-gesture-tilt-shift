import UIKit
import Flutter
import GPUImage

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let imageProcessingChannel = FlutterMethodChannel(name: "flutter_native_image",
                                                          binaryMessenger: controller.binaryMessenger)
        imageProcessingChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            // Note: this method is invoked on the UI thread.
            if(call.method == "adjustImage") {
                result(self?.adjustImage(call))
            }
            
            
            
            /*else{
             result(FlutterMethodNotImplemented)
             return
             }*/
        })
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func adjustImage(_ call: FlutterMethodCall) -> String {
        
        guard let args = call.arguments else {
            print("iOS could not recognize flutter arguments in method: (sendParams)")
            fatalError()
        }
        
        print("#=>args", args)
        
        guard let myArgs = args as? [String: Any],
            let fileName = myArgs["file_name"] as? String,
            let tiltX = myArgs["tiltX"] as? Double,
            let tiltY = myArgs["tiltY"] as? Double,
            let tiltRadius = myArgs["tiltRadius"] as? Double else {
                fatalError()
        }
        
        /*
         It seems there's an issue with above CIFilter so,
         to show that TiltShift works, we need to omit the usage for a while
         */
        
        guard var newImg = UIImage(named: fileName) else {
            fatalError()
        }
        
//        newImg = newImg.byFixingOrientation()
        
//        newImg = applyFilterTiltShift(
//            image: newImg,
//            excludeCircleRadius: 0.3, // unblurred area
//            blurRadiusInPixels: 0.73, // blur
//            excludeCirclePoint: CGPoint(
//                x: CGFloat(tiltX),
//                y: CGFloat(tiltY)
//            )
//        )
        
        let originalOrientation = newImg.imageOrientation
        
        print("=>ImageOrientation",
              originalOrientation.string)
        
        /* Please read these.
         Keyword: Exif orientation
         https://www.impulseadventure.com/photo/exif-orientation.html
         https://developer.apple.com/documentation/uikit/uiimage/orientation
         */
        
        newImg = {
            switch newImg.imageOrientation {
            case .up:
                return doEffect(
                    image: UIImage(
                        cgImage: newImg.cgImage!,
                        scale: 1,
                        orientation: .up
                    ),
                    point: CGPoint(
                        x: tiltX,
                        y: 1.0 - tiltY
                    )
                )
            case .down:
                return doEffect(
                    image: UIImage(
                        cgImage: newImg.cgImage!,
                        scale: 1,
                        orientation: .up
                    ),
                    point: CGPoint(
                        x: 1.0 - tiltX,
                        y: tiltY
                    )
                )
            case .left:
                return doEffect(
                    image: UIImage(
                        cgImage: newImg.cgImage!,
                        scale: 1,
                        orientation: .up
                    ),
                    point: CGPoint(
                        x: tiltX,
                        y: tiltY
                    )
                )
            case .right:
                return doEffect(
                    image: UIImage(
                        cgImage: newImg.cgImage!,
                        scale: 1,
                        orientation: .up
                    ),
                    point: CGPoint(
                        x: tiltY,
                        y: tiltX
                    )
                )
            case .upMirrored:
                fatalError("unimplemented")
            case .downMirrored:
                fatalError("unimplemented")
            case .leftMirrored:
                fatalError("unimplemented")
            case .rightMirrored:
                fatalError("unimplemented")
            @unknown default:
                fatalError("unimplemented")
            }
        }()
        
        newImg = UIImage(
            cgImage: newImg.cgImage!,
            scale: 1,
            orientation: originalOrientation
        )
        
        guard let data = newImg.jpegData(compressionQuality: 1.0) else {
            fatalError()
        }
        
        let dirPath = getDocumentsDirectory()
        let imageFileUrl = dirPath.appendingPathComponent(
            "imgs/_adjustedImage-\(UUID()).jpg"
        )
        do {
            try data.write(to: imageFileUrl)
            print("Successfully saved image at path: \(imageFileUrl.path)")
            return(imageFileUrl.path)
        } catch {
            print("Error saving image: \(error)")
            fatalError()
        }
        
        
    }
    
    private func applyBrigtness(image: UIImage, brightness: CGFloat) -> UIImage {
        guard let imgPict = GPUImagePicture(image: image) else { fatalError() }
        
        let filter = GPUImageBrightnessFilter()
        filter.brightness = brightness
        
        imgPict.addTarget(filter)
        filter.useNextFrameForImageCapture()
        imgPict.processImage()
        return filter.imageFromCurrentFramebuffer(with: image.imageOrientation)
    }
    
    private func applyContrast(image: UIImage, contrast: CGFloat) -> UIImage {
        guard let imgPict = GPUImagePicture(image: image) else { fatalError() }
        
        let filter = GPUImageContrastFilter()
        filter.contrast = contrast
        
        imgPict.addTarget(filter)
        filter.useNextFrameForImageCapture()
        imgPict.processImage()
        return filter.imageFromCurrentFramebuffer(with: image.imageOrientation)
    }
    
    private func applySaturation(image: UIImage, saturation: CGFloat) -> UIImage {
        guard let imgPict = GPUImagePicture(image: image) else { fatalError() }
        
        let filter = GPUImageSaturationFilter()
        filter.saturation = saturation
        
        imgPict.addTarget(filter)
        filter.useNextFrameForImageCapture()
        imgPict.processImage()
        return filter.imageFromCurrentFramebuffer(with: image.imageOrientation)
    }
    
    private func applyFilterTiltShift(image: UIImage,
                                      excludeCircleRadius: Float? = nil,
                                      excludeBlurSize: Float? = nil,
                                      blurRadiusInPixels: CGFloat? = nil,
                                      aspectRatio: Float? = nil,
                                      excludeCirclePoint: CGPoint? = nil) -> UIImage {
        let imgPict = GPUImagePicture(image: image)!
        
        let filter = TaliooTiltShiftRadialFilter()
        filter.excludeCircleRadius = excludeCircleRadius ?? filter.excludeCircleRadius
        filter.excludeBlurSize = excludeBlurSize ?? filter.excludeBlurSize
        filter.blurRadiusInPixels = blurRadiusInPixels ?? filter.blurRadiusInPixels
        filter.aspectRatio = aspectRatio ?? filter.aspectRatio
        filter.excludeCirclePoint = excludeCirclePoint ?? filter.excludeCirclePoint
        
        imgPict.addTarget(filter)
        filter.useNextFrameForImageCapture()
        imgPict.processImage()
        return filter.imageFromCurrentFramebuffer(with: image.imageOrientation)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private lazy var ciContext = CIContext(options: nil)
    
    /// TiltShift Image Effect
    /// - Parameters:
    ///   - image: image
    ///   - point: normalized point (0.0 - 1.0)
    func doEffect(image: UIImage, point: CGPoint) -> UIImage {
        guard let ciImageOrig = CIImage(image: image) else { fatalError() }
        
        let mPoint = CGPoint(
            x: image.size.width * point.x,
            y: image.size.height * point.y
        )
        
        print("Point orig", point, "mLocation", mPoint)
        
        let blurEffect = CIFilter(name: "CIGaussianBlur")!
        blurEffect.setValue(ciImageOrig, forKey: kCIInputImageKey)
        blurEffect.setValue(500.0, forKey: kCIInputRadiusKey)
        
        let radialGradient = CIFilter(name: "CIRadialGradient")!
        radialGradient.setValue(
            CIVector(x: mPoint.x, y: mPoint.y),
            forKey: "inputCenter")
        radialGradient.setValue(
            NSNumber(value: 75),
            forKey: "inputRadius0")
        radialGradient.setValue(
            NSNumber(value: 74),
            forKey: "inputRadius1")
        
        let blend = CIFilter(name: "CIBlendWithMask")!
        blend.setValue(blurEffect.outputImage!,
                       forKey: kCIInputImageKey)
        blend.setValue(ciImageOrig,
                       forKey: kCIInputBackgroundImageKey)
        blend.setValue(radialGradient.outputImage!,
                       forKey: kCIInputMaskImageKey)
        
        let filteredImageData = blend
            .value(forKey: kCIOutputImageKey)
            .flatMap({ $0 as? CIImage })!
            .cropped(to: ciImageOrig.extent)
        
        guard let cgImage = ciContext
            .createCGImage(filteredImageData, from: filteredImageData.extent)
            else { fatalError() }
        
        let finalImage = UIImage(
            cgImage: cgImage,
            scale: image.scale,
            orientation: image.imageOrientation
        )
        
        return finalImage
    }
}

extension UIImage.Orientation {
    var string: String {
        switch self {
        case .up:
            return "up"
        case .down:
            return "down"
        case .left:
            return "left"
        case .right:
            return "right"
        case .upMirrored:
            return "upMirrored"
        case .downMirrored:
            return "downMirrored"
        case .leftMirrored:
            return "leftMirrored"
        case .rightMirrored:
            return "rightMirrored"
        @unknown default:
            return "unknown default \(self.rawValue)"
        }
    }
}


extension UIImage {

    func byFixingOrientation(andResizingImageToNewSize newSize: CGSize? = nil) -> UIImage {

        guard let cgImage = self.cgImage else { return self }

        let orientation = self.imageOrientation
        guard orientation != .up else { return UIImage(cgImage: cgImage, scale: 1, orientation: .up) }

        var transform = CGAffineTransform.identity
        let size = newSize ?? self.size

        if (orientation == .down || orientation == .downMirrored) {
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: .pi)
        }
        else if (orientation == .left || orientation == .leftMirrored) {
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2)
        }
        else if (orientation == .right || orientation == .rightMirrored) {
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: -(CGFloat.pi / 2))
        }

        if (orientation == .upMirrored || orientation == .downMirrored) {
            transform = transform.translatedBy(x: size.width, y: 0);
            transform = transform.scaledBy(x: -1, y: 1)
        }
        else if (orientation == .leftMirrored || orientation == .rightMirrored) {
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }

        // Now we draw the underlying CGImage into a new context, applying the transform calculated above.
        guard let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height),
                                  bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0,
                                  space: cgImage.colorSpace!, bitmapInfo: cgImage.bitmapInfo.rawValue)
        else {
            return UIImage(cgImage: cgImage, scale: 1, orientation: orientation)
        }

        ctx.concatenate(transform)

        // Create a new UIImage from the drawing context
        switch (orientation) {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }

        return UIImage(cgImage: ctx.makeImage() ?? cgImage, scale: 1, orientation: .up)
    }
}
