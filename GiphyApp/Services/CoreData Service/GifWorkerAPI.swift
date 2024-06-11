//
//  GifWorkerAPI.swift
//  GiphyApp
//
//  Created by Shishir Ahmed on 1/6/24.
//

import Foundation
import FLAnimatedImage

protocol GifWorkerAPI {
    func getGifs(completion: ([Data]) -> Void)
    func add(imagesData: [Data])
}
