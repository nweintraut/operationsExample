//
//  RVPhotoRecord.swift
//  ClassicPhotos
//
//  Created by Neil Weintraut on 1/21/17.
//  Copyright © 2017 raywenderlich. All rights reserved.
//

import UIKit
enum PhotoRecordState {
    case New, Downloaded, Filtered, Failed
    var description: String {
        switch(self) {
        case .New:
            return "New"
        case .Downloaded:
            return "Downloaded"
        case .Filtered:
            return "Filtered"
        case .Failed:
            return "Failed"
        }
    }
}
class RVPhotoRecord {
    var name: String
    var url: URL
    var state = PhotoRecordState.New
    var image = UIImage(named: "Placeholder")
    var identifier = Date().timeIntervalSince1970
    var indexPath: IndexPath? = nil
    
    init(name: String, url: URL) {
        self.name = name
        self.url = url
    }
    
}
