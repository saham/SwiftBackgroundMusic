
import Foundation
struct Music: Equatable {
    var FileName: String
    var Extension: String
    var Name: String
    var UrlString: String?

    init(urlStr: String? = nil, name: String = "None", FileName: String = "", Extension: String = "mp3") {
        self.FileName = FileName
        self.Extension = Extension
        self.Name = name
        self.UrlString = urlStr
    }
}
