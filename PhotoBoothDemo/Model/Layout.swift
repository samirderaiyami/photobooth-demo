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
    
    init(imgName: String, location: CGRect) {
        self.imgName = imgName
        self.location = location
    }
}

class Layout: Codable {
    
    var id: Int
    var viewName: String
    var indexSelected: Int
    //    var isPotrait: Bool
    //    var customShape: Bool? = false
    //    var shapeImage: String? = ""
    var noOfViews: Int? = 1
    var previewImage: Data?
    var steakers: [Sticker] = []
    var images: [Data] = []

    init(id: Int, viewName: String, indexSelected: Int, noOfViews: Int, steakers: [Sticker]? = [], images: [Data]? = [], previewImage: Data? = nil) {
        self.id = id
        self.viewName = viewName
        self.indexSelected = indexSelected
        self.noOfViews = noOfViews
        self.steakers = steakers ?? []
        self.images = images ?? []
        self.previewImage = previewImage
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
        if let index = userVideos.firstIndex(where: {$0.id == VideoModel.id}) {
            userVideos[index] = VideoModel
        } else {
            userVideos.insert(VideoModel, at: 0)
        }
        let videosData = try! JSONEncoder().encode(userVideos)
        UserDefaults.standard.set(videosData, forKey: CUserDefaultsKey.userSavedVideos)
    }

}
