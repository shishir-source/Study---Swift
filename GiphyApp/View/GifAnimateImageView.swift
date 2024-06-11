//
//  GifAnimateImageView.swift
//  GiphyApp
//
//  Created by Shishir Ahmed on 1/6/24.
//

import UIKit
import FLAnimatedImage

let imageCache = NSCache<AnyObject, AnyObject>()

class GIFAnimateImageView: FLAnimatedImageView {
    var imageUrlString: String?
    var imageData: Data?
    
    func loadImage(data: Data ) {
        imageData = data
        
        animatedImage = nil
        
        if let imageFromCache = imageCache.object(forKey: data.count as AnyObject) as? FLAnimatedImage {
            self.animatedImage = imageFromCache
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            let imageToCache = FLAnimatedImage(animatedGIFData: data, optimalFrameCacheSize: 0, predrawingEnabled: false)
            DispatchQueue.main.async(execute: {
                if self.imageData?.count == data.count {
                    self.animatedImage = imageToCache
                }
                imageCache.setObject(imageToCache!, forKey: data.count as AnyObject)
            })
        }

    }
    
    func loadImage(_ mediaURL: String) {
        imageUrlString = mediaURL
        
        let url = URL(string: "\(mediaURL)")
        
        animatedImage = nil
        
        if let imageFromCache = imageCache.object(forKey: url as AnyObject) as? FLAnimatedImage {
            self.animatedImage = imageFromCache
            return
        }

        URLSession.shared.dataTask(with: url!, completionHandler: { (data, respones, error) in
            
            if error != nil {
                print(error ?? "")
                return
            }
            let imageToCache = FLAnimatedImage(animatedGIFData: data, optimalFrameCacheSize: 0, predrawingEnabled: false)
            DispatchQueue.main.async(execute: {
                if self.imageUrlString == mediaURL {
                    self.animatedImage = imageToCache
                }
                
                imageCache.setObject(imageToCache!, forKey: url as AnyObject)
            })
            
        }).resume()
    }
}

