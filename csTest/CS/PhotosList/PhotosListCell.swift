//
//  PhotosListCell.swift
//  csTest
//
//  Created by Denis Kudinov on 27/01/2017.
//  Copyright © 2017 Denis Kudinov. All rights reserved.
//

import UIKit

class PhotosListCell: UICollectionViewCell {
  
  let photoImageView = UIImageView()
  let wtfView = UIView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(photoImageView)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    photoImageView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
  }
  
  override func prepareForReuse() {
    photoImageView.image = nil
    super.prepareForReuse()
  }
  
  func configure(withImage image: UIImage) {
    photoImageView.image = image
  }
  
}
