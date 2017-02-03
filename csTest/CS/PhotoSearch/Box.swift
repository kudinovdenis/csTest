//
//  Box.swift
//  csTest
//
//  Created by Denis Kudinov on 01/02/2017.
//  Copyright © 2017 Denis Kudinov. All rights reserved.
//

import UIKit

class Box: UIView {
  
  override func layoutSubviews() {
    super.layoutSubviews()
    layer.borderColor = UIColor.blue.cgColor
    layer.borderWidth = 4
  }
  
}
