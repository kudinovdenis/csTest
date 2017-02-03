//
//  Processor.swift
//  csTest
//
//  Created by Denis Kudinov on 03/02/2017.
//  Copyright © 2017 Denis Kudinov. All rights reserved.
//

import Foundation

protocol ProcessorMSVisionDelegate {
  
  func taggingProceed(for photo: PhotoListModel, tags:[String], _ currentProgress: Int, _ totalProgress: Int)
  
}

class Processor {
  
  var processorMSVisionDelegate: ProcessorMSVisionDelegate?
  
  func processPhotos(_ photos: [PhotoListModel], delegate: ProcessorMSVisionDelegate) {
    processorMSVisionDelegate = delegate
    DispatchQueue.global(qos: .userInitiated).async {
      var counter = 0
      for photo in photos {
        autoreleasepool {
          if let tags = Storage.shared.findTags(for: photo) {
            counter += 1
            DispatchQueue.main.async {
              delegate.taggingProceed(for: photo, tags: tags, counter, photos.count)
            }
            return
          }
          guard let image = photo.fullSizeImage() else {
            print("Cannot make fullsize image from asset")
            return
          }
          let tags = MicrosoftImageSearchAPIClient.analyze(image: image)
          //
          Storage.shared.write(photo, tags)
          //
          counter += 1
          DispatchQueue.main.async {
            delegate.taggingProceed(for: photo, tags: tags, counter, photos.count)
          }
        }
      }
    }
  }
  
}
