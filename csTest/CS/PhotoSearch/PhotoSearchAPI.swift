//
//  PhotoSearchAPI.swift
//  csTest
//
//  Created by Denis Kudinov on 27/01/2017.
//  Copyright © 2017 Denis Kudinov. All rights reserved.
//

import Foundation
import Photos

class PhotoSearch {
  
  var allPhotoAssets = [PHAsset]()
  
  lazy var tasksQueue: OperationQueue = {
    var queue = OperationQueue()
    queue.name = "Tasks operation queue"
    queue.qualityOfService = .userInitiated
    return queue
  }()
  
  func getAllPhotos() -> [PhotoListModel] {
    var assets = [PhotoListModel]()
    let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
    collections.enumerateObjects({ collection, idx, stop in
      let fetchResults = PHAsset.fetchAssets(in: collection, options: nil)
      fetchResults.enumerateObjects({ (asset, assetIdx, assetStop) in
        self.allPhotoAssets.append(asset)
        let photoModel = PhotoListModel(asset: asset, photoSearchClient: self)
        assets.append(photoModel)
      })
    })
    return assets
  }
  
  func getPhotoByID(localID: String) -> PhotoListModel? {
    for asset in allPhotoAssets {
      if asset.localIdentifier == localID {
        return PhotoListModel(asset: asset, photoSearchClient: self)
      }
    }
    return nil
  }
  
  func getFullSizeImage(for photo: PhotoListModel) -> UIImage? {
    print("Getting fullsize image for: \(photo.asset)")
    let group = DispatchGroup()
    var output: UIImage?
    group.enter()
    let options = PHImageRequestOptions()
    options.isSynchronous = true
    PHImageManager.default().requestImage(for: photo.asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: options) { (image, map) in
      group.leave()
      output = image
    }
    group.wait()
    return output
  }
  
  func getThumbnail(for photo: PhotoListModel, size: CGSize) -> UIImage? {
    print("Getting thumbnail for: \(photo.asset)")
    let group = DispatchGroup()
    var output: UIImage?
    group.enter()
    let options = PHImageRequestOptions()
    options.isSynchronous = true
    PHImageManager.default().requestImage(for: photo.asset, targetSize: size, contentMode: .aspectFill, options: options) { (image, map) in
      group.leave()
      output = image
    }
    group.wait()
    return output
  }
  
  func requestAuthorizationWithCompletion(handler: @escaping (PHAuthorizationStatus) -> ()) {
    DispatchQueue.main.async {
      PHPhotoLibrary.requestAuthorization(handler)
    }
  }
  
  func authorizationStatus() -> PHAuthorizationStatus {
    return PHPhotoLibrary.authorizationStatus()
  }
  
  func detect(type: String, image: UIImage) -> [CIFeature]? {
    let detector = CIDetector(ofType: type, context: CIContext(), options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
    guard let convertedImage = CIImage(image: image) else {
      print("Cannot convert UIImage to CIImage.")
      return nil
    }
    let features = detector?.features(in: convertedImage)
    return features
  }
  
  func detectFaces(onImage image: UIImage) -> [CIFeature]? {
    return detect(type: CIDetectorTypeFace, image: image)
  }
  
  func detectText(onImage image: UIImage) -> [CIFeature]? {
    return detect(type: CIDetectorTypeText, image: image)
  }
  
}

extension PhotoSearch {
  
  func findAll(with type: String, in photos: [PhotoListModel], progressHandler:(_ processed: Int, _ total: Int) -> ()) -> [PhotoListModel] {
    var output = [PhotoListModel]()
    var counter = 0
    for photo in photos {
      autoreleasepool {
        var features: [CIFeature]?
        if type == CIDetectorTypeFace {
          features = detectFaces(onImage: photo.fullSizeImage()!)
        } else if type == CIDetectorTypeText {
          features = detectText(onImage: photo.fullSizeImage()!)
        } else {
          print("Unsupported type to search")
        }
        if features != nil {
          if (features!.count > 0) {
            print("Found: \(features!)")
            photo.features = features
            output.append(photo)
          } else {
            print("Nothing found on image")
          }
        }
      }
      counter += 1
      print("processed: \(counter) out of \(photos.count)")
      progressHandler(counter, photos.count)
    }
    return output
  }
  
}
