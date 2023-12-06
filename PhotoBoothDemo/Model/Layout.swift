//
//  VideoModel.swift
//  PerfectStopWatchForSprints
//
//  Created by Mac-0006 on 07/12/21.
//

import Foundation

let arrLayouts = [
    Layout(id: 1, viewName: "_4x6Layout1", indexSelected: 0,noOfViews: 3),
    Layout(id: 2, viewName: "_4x6Layout2", indexSelected: 1,noOfViews: 1)
]
    
class Sticker: Codable {
    var imgName: String
    var location: CGRect
    var rotationAngle: CGFloat
    var scale: CGRect
    init(imgName: String, location: CGRect, rotationAngle: CGFloat, scale: CGRect) {
        self.imgName = imgName
        self.location = location
        self.rotationAngle = rotationAngle
        self.scale = scale
    }
}

class Text: Codable {
    var text: String
    var location: CGRect
    var rotationAngle: CGFloat
    var scale: Float
    var scaleRect: CGRect
    var font: String
    var size: CGFloat
    var color: String
    
    init(text: String, location: CGRect, rotationAngle: CGFloat, scale: Float, scaleRect: CGRect, font: String, size: CGFloat, color: String) {
        self.text = text
        self.location = location
        self.rotationAngle = rotationAngle
        self.scale = scale
        self.scaleRect = scaleRect

        self.font = font
        self.size = size
        self.color = color
    }
}

class Layout: Codable {
    
    var id: Int
    var viewName: String
    var indexSelected: Int
    var noOfViews: Int? = 1
    var previewImage: Data?
    var steakers: [Sticker] = []
    var isNewLayout: Bool = false
    var createdAt: Date = Date()
    var backgroundImageName: String = ""
    
    //.. Text
    var texts: [Text] = []

    var layoutBackgroundColor: String? = "ffffff"
    var layoutBackgroundFrame: CGRect?
    var layoutBackgroundRotate: CGFloat = 0.0
    var layoutBackgroundScale: CGRect?

    init(id: Int, viewName: String, indexSelected: Int, noOfViews: Int, steakers: [Sticker]? = [], previewImage: Data? = nil, texts: [Text]? = [], irStickers: [Data]? = [], layoutBackgroundColor: String? = "ffffff", layoutBackgroundFrame: CGRect? = nil, layoutBackgroundRotate: CGFloat = 0.0, layoutBackgroundScale: CGRect? = nil, isNewLayout: Bool? = false, backgroundImageName: String? = nil) {
        self.id = id
        self.viewName = viewName
        self.indexSelected = indexSelected
        self.noOfViews = noOfViews
        self.steakers = steakers ?? []
        self.previewImage = previewImage
        self.texts = texts ?? []
        self.isNewLayout = isNewLayout ?? false
        self.backgroundImageName = backgroundImageName ?? ""
        self.layoutBackgroundColor = layoutBackgroundColor
        self.layoutBackgroundFrame = layoutBackgroundFrame
        self.layoutBackgroundRotate = layoutBackgroundRotate
        self.layoutBackgroundScale = layoutBackgroundScale

    }

    public static func saveUserEditedLayouts(layout: Layout){
        var videosArray:[Layout] = []
        videosArray.append(contentsOf: getUserEditedVideos())
        videosArray.insert(layout, at: 0)
        let videosData = try! JSONEncoder().encode(videosArray)
        UserDefaults.standard.set(videosData, forKey: CUserDefaultsKey.userSavedVideos)
    }
    
    public static func saveGetUsersEditedVideos(layoutArray: [Layout]){
        let videosData = try! JSONEncoder().encode(layoutArray)
        UserDefaults.standard.set(videosData, forKey: CUserDefaultsKey.userSavedVideos)
    }


    public static func getUserEditedVideos() -> [Layout] {
        let placeData = UserDefaults.standard.data(forKey:CUserDefaultsKey.userSavedVideos)
        
        if let placeData = placeData {
            let placeArray = try! JSONDecoder().decode([Layout].self, from: placeData)
            return placeArray
        }
        return []
    }
    
    public static func updateUserEditedVideos(VideoModel: Layout){
        var userVideos = getUserEditedVideos()
        VideoModel.createdAt = Date()
        if let index = userVideos.firstIndex(where: {$0.backgroundImageName == VideoModel.backgroundImageName}), !VideoModel.isNewLayout {
            userVideos[index] = VideoModel
        } else {
            userVideos.insert(VideoModel, at: 0)
        }
        let videosData = try! JSONEncoder().encode(userVideos)
        UserDefaults.standard.set(videosData, forKey: CUserDefaultsKey.userSavedVideos)
        
    }
    
    public static func deleteUserEditedVideos(backgroundImageName: String){
        var userVideos = getUserEditedVideos()
        if let index = userVideos.firstIndex(where: {$0.backgroundImageName == backgroundImageName}) {
            userVideos.remove(at: index)
            let videosData = try! JSONEncoder().encode(userVideos)
            UserDefaults.standard.set(videosData, forKey: CUserDefaultsKey.userSavedVideos)
        }
    }

}
/*
public static func getLolAppGalaryPhotos() -> [String] {
    
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    
    if let dirPath = paths.first {
        let imageDirectory = URL(fileURLWithPath: dirPath).appendingPathComponent("images").absoluteString.replacingOccurrences(of: "file://", with: "")
        let imageLists = (try? FileManager.default.contentsOfDirectory(atPath: imageDirectory))
        
        var arrImageTemp: [String] = []
        arrImageTemp.append(contentsOf: imageLists?.map({ val in
            return imageDirectory+val
        }) ?? [])
        
        return arrImageTemp
    }
    return []
    }
 
 
 
 //.. ACCESS
 vc.selectedImage = try! UIImage(data: Data(contentsOf: URL(fileURLWithPath: "")))

*/

