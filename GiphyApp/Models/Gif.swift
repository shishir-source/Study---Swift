//
//  Gif.swift
//  GiphyApp
//
//  Created by Shishir Ahmed on 1/6/24.
//

import Foundation
import SwiftyJSON
import FLAnimatedImage
import Alamofire


struct Gif {
    let id: String
    let url: String
}

extension Gif {
    init(json: JSON) {
        self.id = json["id"].stringValue
        self.url = json["images"]["fixed_width"]["url"].stringValue
    }
}
