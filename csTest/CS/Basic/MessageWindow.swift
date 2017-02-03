//
//  MessageWindow.swift
//  csTest
//
//  Created by Denis Kudinov on 27/01/2017.
//  Copyright © 2017 Denis Kudinov. All rights reserved.
//

import UIKit

class MessageWindow: UIWindow {
  
  let label = UILabel(frame: CGRect.zero)
  var isShown: Bool = false
  var needCancel = false
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    label.font = UIFont.systemFont(ofSize: 14)
    label.textColor = UIColor.black
    windowLevel = UIWindowLevelStatusBar + 1
    addSubview(label)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    label.frame = frame
  }
  
}
