//
//  ViewController.swift
//  csTest
//
//  Created by Denis Kudinov on 27/01/2017.
//  Copyright © 2017 Denis Kudinov. All rights reserved.
//

import UIKit
import Photos

protocol ViewControllerDelegate: class {
    func selected(_ image: PhotoObject)
}

class ViewController: BasicViewController {
    
    let photoSearchClient = PhotoSearch()
    
    let startButton = UIButton(type: .system)
    let openGrouppedViewButton = UIButton(type: .system)
    var photosCollectionView: UICollectionView!
    var processedImageView: UIImageView!
    let processor = Processor()
    
    weak var delegate: ViewControllerDelegate?
    
    var assets = [PhotoListModel]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupView(frame: CGRect) {
        setupStartButton()
        setupCollectionView()
        setupProcessedImageView()
        setupOpenGrouppedViewButton()
    }
    
    func setupStartButton() {
        view.addSubview(startButton)
        startButton.setTitle("Start", for: .normal)
        //    startButton.addTarget(self, action: #selector(processAllPhotos), for: .touchUpInside)
        startButton.addTarget(self, action: #selector(processAllWithMSServers), for: .touchUpInside)
    }
    
    func setupOpenGrouppedViewButton() {
        view.addSubview(openGrouppedViewButton)
        openGrouppedViewButton.setTitle("Open Groupped view", for: .normal)
        openGrouppedViewButton.addTarget(self, action: #selector(openGrouppedController), for: .touchUpInside)
    }
    
    override func viewWillLayoutSubviews() {
        print("VC - \(self.view.frame)")
        super.viewWillLayoutSubviews()
        startButton.frame = CGRect(x: 100, y: 100, width: 100, height: 50)
        photosCollectionView.frame = CGRect(x: 0,
                                            y: startButton.frame.origin.y + startButton.frame.size.height,
                                            width: view.frame.width,
                                            height: view.frame.height - (startButton.frame.origin.y + startButton.frame.size.height))
        openGrouppedViewButton.frame = CGRect(x: startButton.frame.maxX + 20, y: startButton.frame.minY, width: 150, height: 50)
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        let itemSide = view.frame.width / 5
        layout.itemSize = CGSize(width: itemSide, height: itemSide)
        photosCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        view.addSubview(photosCollectionView)
        photosCollectionView.backgroundColor = UIColor.white
        photosCollectionView.register(PhotosListCell.self, forCellWithReuseIdentifier: "PhotosListCell")
        photosCollectionView.dataSource = self
        photosCollectionView.delegate = self
    }
    
    func setupProcessedImageView() {
        processedImageView = UIImageView(frame: CGRect(x: 20, y: 20, width: view.frame.size.width - 40, height: view.frame.size.height - 40))
        view.addSubview(processedImageView)
        processedImageView.alpha = 0.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        photoSearchClient.requestAuthorizationWithCompletion { status in
            switch status {
            case .authorized:
                self.showMessage(withString: "Access granted.")
                self.updatePhotosList()
                break
            case .denied:
                fallthrough
            case .notDetermined:
                fallthrough
            case .restricted:
                self.showMessage(withString: "Give the access to photos!")
                break
            }
        }
    }
    
    func updatePhotosList() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.assets = self.photoSearchClient.getAllPhotos()
            DispatchQueue.main.async {
                self.photosCollectionView.reloadData()
            }
        }
    }
    
    func processAllWithMSServers() {
        processor.processPhotos(self.assets, delegate: self)
    }
    
    func openGrouppedController() {
        guard let topTags = Storage.shared.topTags(withLimit: 120) else {
            print("Nothing to show!")
            return
        }
        
        var taggedPhotoGroups = [TaggedPhotoGroup]()
        for tagObject in topTags {
            let taggedPhotoGroup = TaggedPhotoGroup()
            taggedPhotoGroup.tag = tagObject.stringValue
            for photo in tagObject.photos {
                if let photoModel = photoSearchClient.getPhotoByID(localID: photo.assetID!) {
                    taggedPhotoGroup.photoModels.append(photoModel)
                } else {
                    print("Cannot convert photo with ID to Model")
                }
            }
            taggedPhotoGroups.append(taggedPhotoGroup)
        }
        let controller = GrouppingController(frame: view.bounds, tagGroups: taggedPhotoGroups)
        self.messageWindow.isUserInteractionEnabled = false
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func processAllPhotos() {
        DispatchQueue.global(qos: .userInitiated).async {
            let facedPhotos = self.photoSearchClient.findAll(with: CIDetectorTypeFace, in: self.assets, progressHandler: { processed, total in
                //      let facedPhotos = self.photoSearchClient.findAll(with: CIDetectorTypeText, in: self.assets, progressHandler: { processed, total in
                DispatchQueue.main.async {
                    self.showMessage(withString: "Processed \(processed) out of \(total)")
                }
            })
            
            for photo in facedPhotos {
                autoreleasepool {
                    let image = photo.fullSizeImage()
                    let group = DispatchGroup()
                    group.enter()
                    DispatchQueue.main.sync {
                        for feature in photo.features! {
                            var box: Box?
                            if let textFeature = feature as? CITextFeature {
                                box = Box(frame: self.coordinates(forBoxInside: textFeature.bounds, inView: self.processedImageView, relativeToImage: image!))
                            } else if let faceFeature = feature as? CIFaceFeature {
                                box = Box(frame: self.coordinates(forBoxInside: faceFeature.bounds, inView: self.processedImageView, relativeToImage: image!))
                            } else {
                                print("Unsopported feature type. Unable to create box")
                            }
                            self.processedImageView.addSubview(box!)
                        }
                        self.processedImageView.image = image
                        print("Start showing image")
                        UIView.animate(withDuration: 1, animations: {
                            self.processedImageView.alpha = 1
                        }, completion: { success in
                            print("Completed showing image")
                            UIView.animate(withDuration: 2, animations: {
                                self.processedImageView.alpha = 0
                            }, completion: { success in
                                print("Completed hiding image")
                                for subview in self.processedImageView.subviews {
                                    subview.removeFromSuperview()
                                }
                                group.leave()
                            })
                        })
                    }
                    group.wait()
                }
            }
        }
    }
    
    func coordinates(forBoxInside rect: CGRect, inView view: UIView, relativeToImage image: UIImage) -> CGRect {
        let relativeCoords = CGRect(x: rect.origin.x / image.size.width,
                                    y: rect.origin.y / image.size.height,
                                    width: rect.width / image.size.width,
                                    height: rect.height / image.size.height)
        return CGRect(x: relativeCoords.origin.x * view.frame.width,
                      y: relativeCoords.origin.y * view.frame.height,
                      width: relativeCoords.size.width * view.frame.width,
                      height: relativeCoords.size.height * view.frame.height)
    }
    
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("Configuring: \(indexPath.item)")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotosListCell", for: indexPath) as? PhotosListCell
        let photo = assets[indexPath.item]
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
}

extension ViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = self.assets[indexPath.row]
        guard let realmPhoto = Storage.shared.realm.objects(PhotoObject.self).filter(NSPredicate(format: "assetID = %@", photo.asset.localIdentifier)).first else { return }
        self.delegate?.selected(realmPhoto)
    }
}

extension ViewController: ProcessorMSVisionDelegate {
    
    func taggingProceed(for photo: PhotoListModel, tags:[String], _ currentProgress: Int, _ totalProgress: Int) {
        self.showMessage(withString: "\(currentProgress) / \(totalProgress). Tags: \(tags.joined(separator: ", "))")
    }
    
}

