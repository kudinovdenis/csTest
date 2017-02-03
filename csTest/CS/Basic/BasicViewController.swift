//
//  BasicViewController.swift
//  csTest
//
//  Created by Denis Kudinov on 27/01/2017.
//  Copyright © 2017 Denis Kudinov. All rights reserved.
//

import UIKit

class BasicViewController: UIViewController {
  
  let messageWindow = MessageWindow(frame: CGRect.zero)
  
  init(frame: CGRect) {
    super.init(nibName: nil, bundle: nil)
    view = UIView(frame: frame)
    view.backgroundColor = UIColor.white
    setupMessageWindow()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    messageWindow.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)
  }
  
  func showMessage(withString string: String) {
    messageWindow.label.text = string
    self.messageWindow.needCancel = false
    showMessageWindowIfNeeded()
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      if self.messageWindow.needCancel {
        self.hideMessageWindowIfNeeded()
      }
    }
  }
  
  private func showMessageWindowIfNeeded() {
    if (messageWindow.isShown) {
      return
    }
    messageWindow.isShown = true
    messageWindow.isHidden = false
    UIView.animate(withDuration: 0.5, animations: {
      self.messageWindow.alpha = 1.0
      self.messageWindow.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100)
    }) { _ in
      self.messageWindow.needCancel = true
    }
  }
  
  private func hideMessageWindowIfNeeded() {
    if (!messageWindow.isShown) {
      return
    }
    UIView.animate(withDuration: 0.5, animations: { 
      self.messageWindow.alpha = 0.0
      self.messageWindow.frame = CGRect(x: 0, y: -100, width: self.view.frame.width, height: 100)
    }) { _ in
      self.messageWindow.isHidden = true
      self.messageWindow.isShown = false
    }
  }
  
  func setupMessageWindow() {
    messageWindow.isHidden = true
    view.addSubview(messageWindow)
  }
  
}
