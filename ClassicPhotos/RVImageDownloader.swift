//
//  RVImageDownloader.swift
//  ClassicPhotos
//
//  Created by Neil Weintraut on 1/21/17.
//  Copyright © 2017 raywenderlich. All rights reserved.
//

import UIKit
class RVImageDownloader: Operation {
    let photoRecord: RVPhotoRecord
    init(photoRecord: RVPhotoRecord) {
        self.photoRecord = photoRecord
    }
    
    override func main() {
        if self.isCancelled { return }
        do {
            let imageData = try Data(contentsOf: self.photoRecord.url)
            if self.isCancelled { return }
            if !imageData.isEmpty {
                if let image = UIImage(data: imageData) {
                    //print("IN \(self.classForCoder).main, have image for \(photoRecord.identifier)")
                    self.photoRecord.image = image
                    self.photoRecord.state = .Downloaded
                    return
                } else {
                    self.photoRecord.state = .Failed
                    return
                }
            } else {
                self.photoRecord.state = .Failed
                return
            }
        } catch {
            if self.isCancelled { return }
            self.photoRecord.state = .Failed
            return
        }
    }
}
