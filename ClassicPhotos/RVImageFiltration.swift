//
//  RVImageFiltration.swift
//  ClassicPhotos
//
//  Created by Neil Weintraut on 1/21/17.
//  Copyright © 2017 raywenderlich. All rights reserved.
//

import UIKit
class RVImageFiltration: Operation {
    var photoRecord: RVPhotoRecord
    init(photoRecord: RVPhotoRecord){
        self.photoRecord = photoRecord
    }
    override func main() {
        if self.isCancelled  { return }
        if self.photoRecord.state != .Downloaded { return }
        if let image = self.photoRecord.image {
            if let filteredImage = self.applySepiaFilter(image: image) {
                self.photoRecord.image = filteredImage
                self.photoRecord.state = .Filtered
            }
        }
        
    }
    func applySepiaFilter(image: UIImage) -> UIImage? {
        if let data = UIImagePNGRepresentation(image) {
            if let inputImage = CIImage(data: data) {
                if self.isCancelled { return nil }
                let context = CIContext(options: nil)
                if let filter = CIFilter(name:"CISepiaTone") {
                    filter.setValue(inputImage, forKey: kCIInputImageKey)
                    filter.setValue(0.8, forKey: "inputIntensity")
                    if let outputImage = filter.outputImage {
                        if self.isCancelled { return nil }
                        if let outImage = context.createCGImage(outputImage, from: outputImage.extent) {
                            let returnImage = UIImage(cgImage: outImage)
                            return returnImage
                        }

                    }
                }

            }
        }
        return nil
    }
}
