//
//  Storage.swift
//  csTest
//
//  Created by Denis Kudinov on 03/02/2017.
//  Copyright © 2017 Denis Kudinov. All rights reserved.
//

import RealmSwift

class TaggedPhotoGroup {
    
    var tag: String?
    var photoModels: [PhotoListModel]
    
    init() {
        photoModels = [PhotoListModel]()
    }
    
}

class Storage {
    
    static let shared = Storage()
    let realm = try! Realm()
    
}

extension Storage {
    
    func findTags(for photo: PhotoListModel) -> [String]? {
        guard let tags = realm.objects(PhotoObject.self).filter(NSPredicate(format: "assetID = %@", photo.asset.localIdentifier)).first?.tags else {
            print("Cant find tags for photo: \(photo)")
            return nil
        }
        var output = [String]()
        for tagObject in tags {
            output.append(tagObject.stringValue!)
        }
        print("Found tags localy for photo: \(photo) [\(output.joined(separator: ", "))]")
        return output
    }
    
    func findPhotos(for tagString: String) -> [TaggedPhotoGroup]? {
        let tags = realm.objects(TagObject.self).filter(NSPredicate(format: "stringValue CONTAINS[c] %@", tagString))
        var res = [TaggedPhotoGroup]()
        let photoSearchClient = PhotoSearch()
        let _ = photoSearchClient.getAllPhotos()
        for tag in tags {
            let taggedPhotoGroup = TaggedPhotoGroup()
            taggedPhotoGroup.tag = tag.stringValue
            for photo in tag.photos {
                if let photoModel = photoSearchClient.getPhotoByID(localID: photo.assetID!) {
                    taggedPhotoGroup.photoModels.append(photoModel)
                } else {
                    print("Cannot convert photo with ID to Model")
                }
            }
            res.append(taggedPhotoGroup)
        }
        return res
    }
    
    
    private func findTagObject(with string: String) -> TagObject? {
        return realm.objects(TagObject.self).filter(NSPredicate(format: "stringValue = %@", string)).first
    }
    
    func write(_ photo: PhotoListModel, _ tags: [String]) {
        try! realm.write {
            let photoObject = PhotoObject()
            photoObject.assetID = photo.asset.localIdentifier
            for tag in tags {
                if let tagObject = findTagObject(with: tag) {
                    photoObject.tags.append(tagObject)
                    tagObject.photos.append(photoObject)
                } else {
                    let tagObject = TagObject()
                    tagObject.stringValue = tag
                    tagObject.photos.append(photoObject)
                    photoObject.tags.append(tagObject)
                }
            }
            realm.add(photoObject)
        }
    }
    
}


// Groupping
extension Storage {
    
    func topTags(withLimit limit: Int) -> [TagObject]? {
        let result = realm.objects(TagObject.self).sorted { obj1, obj2 -> Bool in
            return obj1.photos.count > obj2.photos.count
        }
        //    let result = realm.objects(TagObject.self).sorted(byKeyPath: "photos.count", ascending: false)
        return Array(result.prefix(limit))
    }
    
}

extension Realm {
    
    class func configureSharedStorageAsDefault() {
        let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.acronis.csTest")!
        let realmPath = directory.appendingPathComponent("db.realm")
        var conf = Realm.Configuration()
        conf.fileURL = realmPath
        Realm.Configuration.defaultConfiguration = conf
    }
    
}




