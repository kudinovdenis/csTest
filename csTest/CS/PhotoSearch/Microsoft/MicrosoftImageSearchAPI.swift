//
//  MicrosoftImageSearchAPI.swift
//  csTest
//
//  Created by Denis Kudinov on 03/02/2017.
//  Copyright © 2017 Denis Kudinov. All rights reserved.
//

import UIKit

class MicrosoftImageSearchAPIClient {
  
  
  /// Analyzing using microsoft API
  ///
  /// - Parameter image: image to analyze
  /// - Returns: Array of tags for photo
  class func analyze(image: UIImage) -> [String] {
    let group = DispatchGroup()
    group.enter()
    guard let data = UIImageJPEGRepresentation(image, 1) else {
      print("Bad image: \(image)")
      group.leave()
      return [String]()
    }
    
    var tags = [String]()
    let analyzeObject = AnalyzeImageRequestObject(resource: data, visualFeatures: [AnalyzeImage.AnalyzeImageVisualFeatures.Tags, AnalyzeImage.AnalyzeImageVisualFeatures.Description])
    do {
      try CognitiveServices.sharedInstance.analyzeImage.analyzeImageWithRequestObject(analyzeObject) { object in
        if object == nil {
          print("No results for image: \(image)")
          group.leave()
          return
        }
        print(object!)
        if let objectTags = object?.tags {
          for tag in objectTags {
            tags.append(tag)
          }
        }
        group.leave()
      }
    } catch {
      print("Cannot process image: \(image)")
      group.leave()
    }
    group.wait()
    return tags
  }
  
}
