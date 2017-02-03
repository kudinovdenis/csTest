//
//  GrouppedCollectionHeader.swift
//  csTest
//
//  Created by Denis Kudinov on 03/02/2017.
//  Copyright © 2017 Denis Kudinov. All rights reserved.
//

import UIKit

class GrouppedCollectionHeader: UICollectionReusableView {
  
  let label = UILabel(frame: CGRect.zero)
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(label)
    label.frame = bounds
    label.textColor = UIColor.black
    label.font = UIFont.systemFont(ofSize: 14)
    label.textAlignment = .center
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
