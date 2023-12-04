//
//  Music.swift
//  MasterMind
//
//  Created by Saham Ghazavi on 2023-11-12.
//

import Foundation
class Music:Equatable {
    static func == (lhs: Music, rhs: Music) -> Bool {
        return lhs.FileName == rhs.FileName &&
        lhs.Extension == rhs.Extension  &&
        lhs.Name == rhs.Name
    }
    
    internal init(urlStr:String? = nil,name:String = "None", FileName: String = "" , Extension: String = "mp3") {
        self.FileName = FileName
        self.Extension = Extension
        self.Name = name
        self.UrlString = urlStr
    }
    
    var FileName:String    // Actual filename on the file system
    var Extension:String   // Actual extension on the file system
    var Name:String        // User facing name
    var UrlString:String?  // Can be used to store the link to the actual file
}
