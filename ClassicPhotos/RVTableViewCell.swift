//
//  RVTableViewCell.swift
//  ClassicPhotos
//
//  Created by Neil Weintraut on 1/21/17.
//  Copyright © 2017 raywenderlich. All rights reserved.
//

import UIKit
class RVTableViewCell: UITableViewCell {

    var photoRecord: RVPhotoRecord? = nil
    var operation: Operation? = nil
    
    func configure() {
        if let record = photoRecord {
            self.textLabel?.text = record.name
            self.imageView?.image = record.image
            watcher()
        }
    }
    
    func watcher() {
        if self.accessoryView == nil {
            self.accessoryView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        }
        let indicator = self.accessoryView as! UIActivityIndicatorView
        if let record = self.photoRecord {
            switch(record.state) {
            case .Filtered:
                if let current = self.photoRecord {
                    if current.identifier == record.identifier {
                        indicator.stopAnimating()
                    }
                }

            case .Failed:
                if let current = self.photoRecord {
                    if current.identifier == record.identifier {
                        indicator.stopAnimating()
                        self.textLabel?.text = "Failed to Load"
                    }
                }

            case .New:
                print("In \(self.classForCoder). New")
                if let current = self.photoRecord {
                    if current.identifier == record.identifier {
                        indicator.startAnimating()
                        self.imageView?.image = record.image
                    }
                }
         //       self.startOperationsForPhotoRecord(photoDetails: record, indexPath: indexPath)
            case .Downloaded:
                print("In \(self.classForCoder). Downloaded")
                if let current = self.photoRecord {
                    if current.identifier == record.identifier {
                        indicator.startAnimating()
                        self.imageView?.image = record.image
                    }
                }
                //  print("In \(self.classForCoder) photo \(photoDetails.identifier) downloaded")

        //        self.startOperationsForPhotoRecord(photoDetails: record, indexPath: indexPath)
            }
        } else {
            print("In \(self.classForCoder).watcher, no record")
        }
        
    }
    
    override func prepareForReuse() {
        self.photoRecord = nil
        self.operation = nil
        super.prepareForReuse()
    }
}
