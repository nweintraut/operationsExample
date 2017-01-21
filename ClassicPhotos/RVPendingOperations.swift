//
//  RVPendingOperations.swift
//  ClassicPhotos
//
//  Created by Neil Weintraut on 1/21/17.
//  Copyright © 2017 raywenderlich. All rights reserved.
//

import Foundation

class RVPendingOperations {
    lazy var downloadsInProgress = [TimeInterval: Operation]()
    lazy var downloadQueue: OperationQueue = {
       let queue = OperationQueue()
        queue.name = "Image Download Queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    lazy var filtrationsInProgress = [TimeInterval : Operation]()
    lazy var filtrationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "Image Filtration Queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
}
