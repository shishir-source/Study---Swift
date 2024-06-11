//
//  ListGifsViewController.swift
//  GiphyApp
//
//  Created by Shishir Ahmed on 1/6/24.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol ListGifsDisplayLogic: class {
    func displayFetchedTrendingGifs(viewModel: ListGifs.FetchGifs.ViewModel)
    func displaySearchedGifs(viewModel: ListGifs.FetchGifs.ViewModel)
    func displayFetchedManagedGifs(viewModel: ListGifs.FetchManagedGifs.ViewModel)
}

class ListGifsViewController: UICollectionViewController, ListGifsDisplayLogic {
    let cellId = "GifCell"
    let searchController = UISearchController(searchResultsController: nil)
    
    var interactor: ListGifsBusinessLogic?
    var router: (NSObjectProtocol & ListGifsRoutingLogic & ListGifsDataPassing)?
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup() {
        let viewController = self
        let interactor = ListGifsInteractor()
        let presenter = ListGifsPresenter()
        let router = ListGifsRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Gifs"
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            navigationItem.titleView = searchController.searchBar
        }
        definesPresentationContext = true
    }
    
    // MARK: Routing
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
    
    var displayedGifs: [ListGifs.FetchGifs.ViewModel.DisplayedGif] = []
    var displayedManagedGifs: [ListGifs.FetchManagedGifs.ViewModel.DisplayedAnimatedImage] = []
    var isManagedGif = false
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Giphy"
        setupSearchController()
        
        fetchManagedGifs()
        if Reachability.isConnectedToInternet() {
            fetchTrendingGifs()
        }
    }
    
    // MARK: Request Interactor
    
    func fetchTrendingGifs() {
        let request = ListGifs.FetchGifs.Request()
        interactor?.fetchTrendingGifs(request: request)
    }
    
    @objc func searchGifs(phrase: String) {
        let request = ListGifs.FetchGifs.Request(phrase: phrase)
        interactor?.searchGif(request: request)
        isManagedGif = false
    }
    
    func fetchManagedGifs() {
        let request = ListGifs.FetchManagedGifs.Request()
        interactor?.fetchManagedGifs(request: request)
        isManagedGif = true
    }
    
    func fetchImageDataInBackground(urls: [String]) {
        let request = ListGifs.FetchGifs.Request(urls: urls)
        interactor?.fetchImagesData(request: request)
    }
    
    // MARK: ListGifDisplayLogic protocol
    
    func displayFetchedTrendingGifs(viewModel: ListGifs.FetchGifs.ViewModel) {
        isManagedGif = false
        self.displayedGifs = viewModel.displayedGifs
        let urls = viewModel.displayedGifs.map { $0.url }
        runOnMainThread()
        fetchImageDataInBackground(urls: urls)
    }
    
    func displaySearchedGifs(viewModel: ListGifs.FetchGifs.ViewModel) {
        displayedGifs = viewModel.displayedGifs
        runOnMainThread()
    }
    
    func displayFetchedManagedGifs(viewModel: ListGifs.FetchManagedGifs.ViewModel) {
        displayedManagedGifs = viewModel.displayedGifImages
        runOnMainThread()
    }
    
    private func runOnMainThread() {
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Reachability.isConnectedToInternet() ? displayedGifs.count : displayedManagedGifs.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! GifCell
        cell.listGifsVC = self
        
        if Reachability.isConnectedToInternet() {
            if isManagedGif {
                cell.animatedViewModel = displayedManagedGifs[indexPath.row]
            } else {
                cell.viewModel = displayedGifs[indexPath.row]
            }
        } else {
            cell.animatedViewModel = displayedManagedGifs[indexPath.row]
        }
        
        return cell
    }
    
    // MARK: Helper properties
    
    let blackBackgroundView = UIView()
    let zoomImageView = GIFAnimateImageView()
    let navBarCoverView = UIView()

    var gifImageView: GIFAnimateImageView?

    func animate(gifImageView: GIFAnimateImageView) {
        self.gifImageView = gifImageView
        
        if let startingFrame = gifImageView.superview?.convert(gifImageView.frame, to: nil) {
            
            gifImageView.alpha = 0
            blackBackgroundView.frame = self.view.frame
            blackBackgroundView.backgroundColor = .black
            blackBackgroundView.alpha = 0
            self.view.addSubview(blackBackgroundView)
            
            navBarCoverView.frame = CGRect(x: 0, y: 0, width: 1000, height: 20+44+52)
            navBarCoverView.backgroundColor = .black
            navBarCoverView.alpha = 0
            
            if let keyWindow = UIApplication.shared.keyWindow {
                keyWindow.addSubview(navBarCoverView)
            }
            
            zoomImageView.backgroundColor = .blue
            zoomImageView.frame = startingFrame
            zoomImageView.isUserInteractionEnabled = true
            zoomImageView.animatedImage = gifImageView.animatedImage
            zoomImageView.contentMode = .scaleAspectFill
            zoomImageView.clipsToBounds = true
            self.view.addSubview(zoomImageView)
            
            zoomImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(zoomOut)))
            
            UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                let height = (self.view.frame.width / startingFrame.width) * startingFrame.height
                let y = self.view.frame.height / 2 - height / 2
                
                self.zoomImageView.frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: height)
                self.blackBackgroundView.alpha = 1
                self.navBarCoverView.alpha = 1
            }, completion: nil)
        }
    }
    
    @objc func zoomOut() {
        if let startingFrame = gifImageView!.superview?.convert(gifImageView!.frame, to: nil) {
            
            UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                self.zoomImageView.frame = startingFrame
                self.blackBackgroundView.alpha = 0
                self.navBarCoverView.alpha = 0
            }, completion: { didComplete in
                self.zoomImageView.removeFromSuperview()
                self.blackBackgroundView.removeFromSuperview()
                self.navBarCoverView.removeFromSuperview()
                self.gifImageView?.alpha = 1
            })
        }
    }
    
}

extension ListGifsViewController: UISearchResultsUpdating {
    
    // MARK: updateSearchResults
    
    func updateSearchResults(for searchController: UISearchController) {
        print("\(String(describing: searchController.searchBar.text))")
        if searchBarIsEmpty() {
            if displayedManagedGifs.count > 0 && !isManagedGif {
                isManagedGif = true
                runOnMainThread()
            } else if displayedManagedGifs.count <= 0 && isManagedGif {
                return
            }
        } else {
            let text = searchController.searchBar.text!
//            searchGifs(phrase: text)
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(searchGifs(phrase:)), object: nil)
            self.perform(#selector(searchGifs(phrase:)), with: text, afterDelay: 0.5)
        }
    }
    
    /// Returns true if the text is empty or nil
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
}

extension ListGifsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 10)) / 2
        return CGSize(width: itemSize, height: itemSize)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView?.collectionViewLayout.invalidateLayout()
    }
}

