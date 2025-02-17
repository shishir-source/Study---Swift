//
//  ShowGifModels.swift
//  GiphyApp
//
//  Created by Shishir Ahmed on 1/6/24.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import FLAnimatedImage

enum ShowGif {
    // MARK: Use cases
    
    enum GetGif {
        struct Request {}
        struct Response {
            var gif: Gif
        }
        struct ViewModel {
            struct DisplayedGif {
                let gif: Gif
            }
            var displayedGif: DisplayedGif
        }
    }
}
