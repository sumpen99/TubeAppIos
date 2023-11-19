//
//  ImageExtensions.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-10-08.
//

import SwiftUI


//compressionQuality = 1.0
//maxSize            = MAX_STORAGE_JPEG_SIZE
//minSize            = MIN_STORAGE_JPEG_SIZE
//maxAttempts        = 10
extension UIImage{
    
    static func downsample(imageAt imageURL: URL,
                    to pointSize: CGSize,
                    scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        
        /*GeometryReader{ reader in
            if let url = URL.localURLForXCAsset(name: "tp3"),
               let img = downsample(imageAt: url, to: CGSize(width: reader.size.width/2.0,
                                                             height: reader.size.height/2.0)){
                Image(uiImage: img)
                  .resizable()
                  .frame(width: reader.size.width/2.0,height: reader.size.height/2.0)
                  .hCenter()
                  .vCenter()
                  .padding()
            }
        }*/
        
        // Create an CGImageSource that represent an image
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions) else {
            return nil
        }
        
        // Calculate the desired dimension
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        
        // Perform downsampling
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return nil
        }
        
        // Return the downsampled image as UIImage
        return UIImage(cgImage: downsampledImage)
    }
    
    func resizeImageIfNeeded(compressionQuality:CGFloat,maxSize:Int,minSize:Int,maxAttempts:Int,data:inout Data?){
        if let dataRaw = self.jpegData(compressionQuality: compressionQuality){
            if dataRaw.count < maxSize{ data = dataRaw; return }
            data = self.compressImage(maxSize: maxSize,
                                      minSize: minSize,
                                      times: maxAttempts)
        }
    }
        
    func compressImage(maxSize: Int, minSize: Int, times: Int) -> Data?{
        var maxQuality: CGFloat = 1.0
        var minQuality: CGFloat = 0.0
        var bestData: Data?
        for _ in 1...times {
            let thisQuality = (maxQuality + minQuality) / 2.0
            guard let data = self.jpegData(compressionQuality: thisQuality) else { return nil }
            let thisSize = data.count
            if thisSize > maxSize {
                maxQuality = thisQuality
            } else {
                minQuality = thisQuality
                bestData = data
                if thisSize >= minSize {
                    return bestData
                }
            }
        }
        return bestData
    }
}
