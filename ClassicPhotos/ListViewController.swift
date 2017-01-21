//
//  ListViewController.swift
//  ClassicPhotos
//
//  Created by Richard Turton on 03/07/2014.
//  Copyright (c) 2014 raywenderlich. All rights reserved.
//

import UIKit
import CoreImage

let dataSourceURL = URL(string:"http://www.raywenderlich.com/downloads/ClassicPhotosDictionary.plist")
private var myContext = 0
class ListViewController: UITableViewController {
  
 // lazy var photos = NSDictionary(contentsOf:dataSourceURL!)!
    var photos = [RVPhotoRecord]()
    let pendingOperations = RVPendingOperations()
    func fetchPhotoDetails() {
        if let url = URL(string:"http://www.raywenderlich.com/downloads/ClassicPhotosDictionary.plist") {
            let request = URLRequest(url: url)
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main, completionHandler: { (urlResponse, data: Data?, error: Error?) in
                if let error = error {
                    print("In \(self.classForCoder) error: \(error.localizedDescription)")
                    return
                } else if let data = data {
                    do {
                        let datasourceDictionary = try PropertyListSerialization.propertyList(from: data, options: PropertyListSerialization.ReadOptions(rawValue: 0), format: nil)
                        if let datasourceDictionary = datasourceDictionary as? NSDictionary {
                            for (key, value) in datasourceDictionary {
                                if let name = key as? String {
                                    if let urlString = value as? String {
                                        if let url = URL(string: urlString) {
                                            let photoRecord = RVPhotoRecord(name: name, url: url)
                                            self.photos.append(photoRecord)
                                        }
                                    }
                                }
                            }
                            //print("In \(self.classForCoder) after getting plist. Count is \(self.photos.count)")
                            self.tableView.reloadData()
                        } else {
                            let alert = UIAlertView(title: "Oops!", message: "Plist didn't download", delegate: nil, cancelButtonTitle: "Cancel")
                            alert.show()
                        }
                    } catch let error {
                        print("In \(self.classForCoder) \(#line), got error \(error.localizedDescription)")
                        let alert = UIAlertView(title: "Oops!", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "Cancel")
                        alert.show()
                    }
                } else {
                    print("In \(self.classForCoder), line \(#line), no error no data")
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            })
        }

    }
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Classic Photos"
    fetchPhotoDetails()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // #pragma mark - Table view data source
  
  override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
    return photos.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath) as? RVTableViewCell {
        if cell.accessoryView == nil {
            cell.accessoryView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        }
       // print("In \(self.classForCoder).cellForRow \(indexPath.row)")
        let indicator = cell.accessoryView as! UIActivityIndicatorView
        if indexPath.row < photos.count {
            let photoDetails = photos[indexPath.row]
            cell.photoRecord = photoDetails
            photoDetails.indexPath = indexPath
            cell.configure()
            switch(photoDetails.state) {
            case .Filtered:
                indicator.stopAnimating()
            case .Failed:
                indicator.stopAnimating()
                cell.textLabel?.text = "Failed to Load"
            case .New:
              //  indicator.startAnimating()
                self.startOperationsForPhotoRecord(photoDetails: photoDetails, indexPath: indexPath)
            case .Downloaded:
              //  print("In \(self.classForCoder) photo \(photoDetails.identifier) downloaded")
                indicator.startAnimating()
                self.startOperationsForPhotoRecord(photoDetails: photoDetails, indexPath: indexPath)
            }
        }
        return cell
    } else {
        print("In \(self.classForCoder). \(#line) shouldn't get here")
        return UITableViewCell()
    }
  }
    

  
    func startOperationsForPhotoRecord(photoDetails: RVPhotoRecord, indexPath: IndexPath) {
        switch(photoDetails.state) {
        case .New:
            startDownloadForRecord(photoDetails: photoDetails, indexPath: indexPath)
        case .Downloaded:
            startFiltrationForRecord(photoDetails: photoDetails, indexPath: indexPath)
        default:
            print("In\(self.classForCoder).start, do nothing for row \(indexPath.row)")
        }
        
    }

    var count = 0
    func testObserver(operation: Operation) {
            if count == 0 {
                count = 1
                operation.addObserver(self, forKeyPath: "isFinished", options: .new, context: &myContext)
            }
            
    
        
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &myContext {
            let path = (keyPath != nil) ? keyPath! : "noKeyPath"
            if let object = object as? Operation {
                if let change = change {
                    print("In \(self.classForCoder).observer of \(path) for operation \(object) with change: \(change[NSKeyValueChangeKey.newKey])")
                }
                
            }
            
        }
        print("GOt something else")
    }
    func startDownloadForRecord(photoDetails: RVPhotoRecord, indexPath: IndexPath) {

               // print("In \(self.classForCoder).startDownload for \(indexPath.row) and Identifier: \(photoDetails.identifier)")
                if let _ = pendingOperations.downloadsInProgress[photoDetails.identifier] {
                    print("In \(self.classForCoder).startDownload for \(indexPath.row) and cellIdentifier: \(photoDetails.identifier)")
                    return
                }
                let downloader = RVImageDownloader(photoRecord: photoDetails)
                downloader.completionBlock = {
                   // print("In \(self.classForCoder).startDownload for \(indexPath.row) and cellIdentifier: \(photoDetails.identifier)  * IN COMPLETION BLOCK")
                    if downloader.isCancelled { return }
                    DispatchQueue.main.async {
                        if let _ = self.pendingOperations.downloadsInProgress.removeValue(forKey: photoDetails.identifier) {
                            self.tableView.reloadRows(at: [indexPath], with: .fade)
                        } else {
                            print("In \(self.classForCoder).startDownload, failed to remove photoRecord with identifier: \(photoDetails.identifier)")
                        }
                    }
                }
                pendingOperations.downloadsInProgress[photoDetails.identifier] = downloader
                pendingOperations.downloadQueue.addOperation(downloader)

                testObserver(operation: downloader)
        
    }
    func startFiltrationForRecord(photoDetails: RVPhotoRecord, indexPath: IndexPath) {
        //print("in \(self.classForCoder).startFiltration for \(indexPath.row)")
        if let cell = self.tableView.cellForRow(at: indexPath) as? RVTableViewCell {
    
                if let _ = pendingOperations.filtrationsInProgress[photoDetails.identifier] { return }
                let filterer = RVImageFiltration(photoRecord: photoDetails)
                filterer.completionBlock = {
                    if filterer.isCancelled { return }
                    DispatchQueue.main.async {
                        if let _ = self.pendingOperations.filtrationsInProgress.removeValue(forKey: photoDetails.identifier) {
                            self.tableView.reloadRows(at: [indexPath], with: .fade)
                        } else {
                            print("In \(self.classForCoder).startFilterations, failed to remove photoRecord with identifier: \(photoDetails.identifier)")
                        }
                    }
                }
                pendingOperations.filtrationsInProgress[photoDetails.identifier] = filterer
                pendingOperations.filtrationQueue.addOperation(filterer)

        } else {
            print("In \(self.classForCoder).startFiltration, cell did not cast row \(indexPath.row)")
        }
        
    }
    
  func applySepiaFilter(_ image:UIImage) -> UIImage? {
    let inputImage = CIImage(data:UIImagePNGRepresentation(image)!)
    let context = CIContext(options:nil)
    let filter = CIFilter(name:"CISepiaTone")
    filter?.setValue(inputImage, forKey: kCIInputImageKey)
    filter!.setValue(0.8, forKey: "inputIntensity")
    if let outputImage = filter!.outputImage {
      let outImage = context.createCGImage(outputImage, from: outputImage.extent)
      return UIImage(cgImage: outImage!)
    }
    return nil
    
  }
  
}
