//
//  ShowGifPresenter.swift
//  GiphyApp
//
//  Created by Shishir Ahmed on 1/6/24.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol ShowGifPresentationLogic {
    func presentGif(response: ShowGif.GetGif.Response)
}

class ShowGifPresenter: ShowGifPresentationLogic {
    weak var viewController: ShowGifDisplayLogic?
    
    // MARK: Do something
    
    func presentGif(response: ShowGif.GetGif.Response) {
        let gif = response.gif
        let displayedGif = ShowGif.GetGif.ViewModel.DisplayedGif(gif: gif)
        let viewModel = ShowGif.GetGif.ViewModel(displayedGif: displayedGif)
        viewController?.displayGif(viewModel: viewModel)
    }
}
