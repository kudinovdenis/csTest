//
//  PhotoListModel.swift
//  csTest
//
//  Created by Denis Kudinov on 31/01/2017.
//  Copyright © 2017 Denis Kudinov. All rights reserved.
//

import UIKit
import Photos

class PhotoListModel {
  
  var photoSearchClient: PhotoSearch
  var asset: PHAsset
  var features: [CIFeature]?
  private var thumbnail: UIImage?
  private var fullsizeImage: UIImage?
  
  init(asset: PHAsset, photoSearchClient: PhotoSearch) {
    self.photoSearchClient = photoSearchClient
    self.asset = asset
  }
  
  func thumbnail(size: CGSize) -> UIImage? {
    if let thumbnail = thumbnail {
      return thumbnail
    }
    self.thumbnail = photoSearchClient.getThumbnail(for: self, size: size)
    return self.thumbnail
  }
  
  func fullSizeImage() -> UIImage? {
//    if let fullsizeImage = fullsizeImage {
//      return fullsizeImage
//    }
//    self.fullsizeImage = photoSearchClient.getFullSizeImage(for: self)
//    return self.fullsizeImage
    return photoSearchClient.getFullSizeImage(for: self)
  }

}
