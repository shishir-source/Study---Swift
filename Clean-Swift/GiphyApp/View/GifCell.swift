//
//  GifCell.swift
//  GiphyApp
//
//  Created by Shishir Ahmed on 1/6/24.
//

import UIKit
import FLAnimatedImage

class GifCell: UICollectionViewCell {
    @IBOutlet weak var gifImageView: GIFAnimateImageView!
    
    private var coreDataWorker: GifWorkerAPI?
    var listGifsVC: ListGifsViewController?
    
    var viewModel: ListGifs.FetchGifs.ViewModel.DisplayedGif? {
        didSet {            
            if let viewModel = viewModel {
                gifImageView.loadImage(viewModel.url)
            }
        }
    }
    
    var animatedViewModel: ListGifs.FetchManagedGifs.ViewModel.DisplayedAnimatedImage? {
        didSet {
            if let viewModel = animatedViewModel {
                gifImageView.loadImage(data: viewModel.gifImage)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        gifImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(animate)))
    }
    
    @objc func animate() {
        listGifsVC?.animate(gifImageView: gifImageView)
    }
    
}
