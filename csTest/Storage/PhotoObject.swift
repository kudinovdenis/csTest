//
//  PhotoObject.swift
//  csTest
//
//  Created by Denis Kudinov on 03/02/2017.
//  Copyright © 2017 Denis Kudinov. All rights reserved.
//

import RealmSwift

class TagObject: Object {
  
  dynamic var stringValue: String? = nil
  
  let photos = List<PhotoObject>()
  
}

class PhotoObject: Object {
  
  dynamic var assetID: String? = nil
  
  let tags = List<TagObject>()
  
}
