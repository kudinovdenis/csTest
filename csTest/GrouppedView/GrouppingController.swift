//
//  GrouppingController.swift
//  csTest
//
//  Created by Denis Kudinov on 03/02/2017.
//  Copyright © 2017 Denis Kudinov. All rights reserved.
//

import UIKit

class GrouppingController: BasicViewController {
  
  var tagGroups: [TaggedPhotoGroup]
  var collectionView: UICollectionView!
  
  init(frame: CGRect, tagGroups: [TaggedPhotoGroup]) {
    self.tagGroups = tagGroups
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupView() {
    setupCollectionView()
  }
  
  func setupCollectionView() {
    let layout = UICollectionViewFlowLayout()
    layout.itemSize = CGSize(width: view.frame.size.width / 5, height: view.frame.size.width / 5)
    layout.headerReferenceSize = CGSize(width: view.frame.size.width, height: 50)
    collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
    view.addSubview(collectionView)
    collectionView.backgroundColor = UIColor.white
    collectionView.register(PhotosListCell.self, forCellWithReuseIdentifier: "PhotosListCell")
    collectionView.register(GrouppedCollectionHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "GrouppedCollectionHeader")
    collectionView.dataSource = self
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    collectionView.frame = view.bounds
  }
  
}

extension GrouppingController: UICollectionViewDataSource {
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return tagGroups.count
  }
  
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return tagGroups[section].photoModels.count
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let photo = tagGroups[indexPath.section].photoModels[indexPath.item]
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotosListCell", for: indexPath) as? PhotosListCell
    let itemSide = view.frame.width / 5
    DispatchQueue.global(qos: .userInitiated).async {
      let thumbnail = photo.thumbnail(size: CGSize(width: itemSide, height: itemSide))
      DispatchQueue.main.async {
        guard let cell = cell else {
          print("Cell deallocated!")
          return
        }
        cell.configure(withImage: thumbnail!)
      }
    }
    return cell!
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    if (kind == UICollectionElementKindSectionHeader) {
      let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "GrouppedCollectionHeader", for: indexPath) as! GrouppedCollectionHeader
      let section = tagGroups[indexPath.section]
      header.label.text = section.tag!
      return header
    }
    return UICollectionReusableView()
  }
  
  
}
