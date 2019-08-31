//
//  EventViewController.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/10.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class EventViewController: UIViewController {
    
    private var isFiltering: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    
    // The search bar
    private let searchController = UISearchController(searchResultsController: nil)

    private var topTabBg: UIVisualEffectView!
    private var topTab: UISegmentedControl!
    private var eventCatalog: UICollectionView!
    private var spinner: UIActivityIndicatorView!
    private var spinnerLabel: UILabel!
    private var emptyLabel: UILabel!
    
    private var shouldFilter: Bool = false
    public static var chosenTags = Set<String>()
    
    private(set) var allEvents = [Event]() {
        didSet {
            self.updateFiltered()
        }
    }
    private var filteredEvents = [Event]()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        title = "Events"
        
        // Search bar setup
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = MAIN_TINT
        searchController.searchBar.placeholder = "Search Events"
        navigationItem.searchController = searchController
//        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        navigationItem.leftBarButtonItem = .init(image: #imageLiteral(resourceName: "options"), style: .plain, target: self, action: #selector(openOptions))
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .refresh, target: self, action: #selector(updateEvents))
        
        topTabBg = {
            let ev = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
            ev.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(ev)
            
            ev.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            ev.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            ev.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            ev.heightAnchor.constraint(equalToConstant: 60).isActive = true
            
            return ev
        }()
        
        topTab = {
            let tab = UISegmentedControl(items: ["All Events", "Trending", "Recommended"])
            if User.current == nil {
                tab.setEnabled(false, forSegmentAt: 1)
                tab.setEnabled(false, forSegmentAt: 2)
            }
            tab.tintColor = MAIN_TINT
            tab.selectedSegmentIndex = 0
            tab.translatesAutoresizingMaskIntoConstraints = false
            topTabBg.contentView.addSubview(tab)
            
            tab.leftAnchor.constraint(equalTo: topTabBg.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
            tab.rightAnchor.constraint(equalTo: topTabBg.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
            tab.centerYAnchor.constraint(equalTo: topTabBg.centerYAnchor).isActive = true
            
            tab.addTarget(self, action: #selector(updateEvents), for: .valueChanged)
            return tab
        }()
        
        topTabBg.layoutIfNeeded()
        
        eventCatalog = {
           let ec = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
            ec.delegate = self
            ec.dataSource = self
            ec.contentInset.top = topTabBg.frame.height + 8
            ec.contentInset.bottom = 8
            ec.scrollIndicatorInsets.top = topTabBg.frame.height
            ec.backgroundColor = .init(white: 0.92, alpha: 1)
            ec.register(EventCell.classForCoder(), forCellWithReuseIdentifier: "event")
            ec.contentInsetAdjustmentBehavior = .always
            ec.translatesAutoresizingMaskIntoConstraints = false
            view.insertSubview(ec, belowSubview: topTabBg)
            
            ec.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            ec.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            ec.topAnchor.constraint(equalTo: topTabBg.topAnchor).isActive = true
            ec.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            return ec
        }()
        
        spinner = {
            let spinner = UIActivityIndicatorView(style: .whiteLarge)
            spinner.color = .lightGray
            spinner.hidesWhenStopped = true
            spinner.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(spinner)
            
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            spinner.centerYAnchor.constraint(equalTo: eventCatalog.centerYAnchor, constant: -5).isActive = true
            
            return spinner
        }()
        
        spinnerLabel = {
            let label = UILabel()
            label.text = "Loading events..."
            label.isHidden = true
            label.font = .systemFont(ofSize: 17, weight: .medium)
            label.textColor = .darkGray
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: spinner.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 10).isActive = true
            
            return label
        }()
        
        emptyLabel = {
            let label = UILabel()
            label.textColor = .darkGray
            label.font = .systemFont(ofSize: 17)
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: eventCatalog.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: eventCatalog.centerYAnchor).isActive = true
            
            return label
        }()
        
        updateEvents()
        NotificationCenter.default.addObserver(self, selector: #selector(filteredByUser), name: NSNotification.Name("user_chose_tags"), object: nil)
    }
    
    @objc private func filteredByUser() {
        shouldFilter = true
        self.updateEvents()
    }

    
    @objc private func updateEvents() {
        //shouldFilter = false
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        spinner.startAnimating()
        spinnerLabel.isHidden = false
        emptyLabel.text = ""
        allEvents.removeAll()
        self.eventCatalog.reloadSections(IndexSet(arrayLiteral: 0))
        
        var parameters = [String : String]()
        if User.current != nil {
            parameters["userId"] = String(User.current!.uuid)
            parameters["userEmail"] = User.current!.email
        }
            
        let url = URL.with(base: API_BASE_URL,
                           API_Name: "events/List", parameters: parameters)!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.spinnerLabel.isHidden = true
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
            
            guard error == nil else {
                DispatchQueue.main.async {
                    self.emptyLabel.text = CONNECTION_ERROR
                    internetUnavailableError(vc: self)
                }
                return
            }
            
            if let eventsList = try? JSON(data: data!).arrayValue {
                var tmp = [Event]()
                for event in eventsList {
                    tmp.append(Event(eventInfo: event))
                }
                DispatchQueue.main.async {
                    self.allEvents = tmp
                    self.emptyLabel.text = tmp.isEmpty ? "No Events" : ""
                    self.eventCatalog.reloadSections(IndexSet(arrayLiteral: 0))
                }
            } else {
                print("Unable to parse '\(String(data: data!, encoding: .utf8)!)'")

                DispatchQueue.main.async {
                    self.emptyLabel.text = SERVER_ERROR
                }
                
                if String(data: data!, encoding: .utf8) == INTERNAL_ERROR {
                    DispatchQueue.main.async {
                        serverMaintenanceError(vc: self)
                    }
                }
            }
        }
        
        task.resume()
    }
    
    @objc private func openOptions() {
        // TODO: filtering options here
        let filter = FilterViewController()
        let nav = UINavigationController(rootViewController: filter)
        nav.navigationBar.tintColor = MAIN_TINT
        nav.navigationBar.barTintColor = .white
        nav.navigationBar.shadowImage = UIImage()
        present(nav, animated: true, completion: nil)
    }
    

}


extension EventViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredEvents.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "event", for: indexPath) as! EventCell
        cell.setupCellWithEvent(event: filteredEvents[indexPath.row], withImage: true)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let detailPage = EventDetailPage()
        detailPage.hidesBottomBarWhenPushed = true
        detailPage.event = filteredEvents[indexPath.row]
        navigationController?.pushViewController(detailPage, animated: true)
    }
}


extension EventViewController: UICollectionViewDelegateFlowLayout {
    var cardWidth: CGFloat {
        if usableWidth < 500 {
            return usableWidth - 16
        } else {
            let numFit = floor(usableWidth / 320)
            return ((usableWidth - 8) / numFit) - 8
        }
    }
    
    var usableWidth: CGFloat {
        return eventCatalog.safeAreaLayoutGuide.layoutFrame.width
    }
    
    var equalSpacing: CGFloat {
        let rowCount = floor(usableWidth / cardWidth)
        let extraSpace = usableWidth - rowCount * cardWidth

        return extraSpace / (rowCount + 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cell = EventCell()
        cell.setupCellWithEvent(event: filteredEvents[indexPath.row])
        return CGSize(width: cardWidth,
                      height: cell.preferredHeight(width: cardWidth))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return equalSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return equalSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: equalSpacing,
                            left: equalSpacing,
                            bottom: equalSpacing,
                            right: equalSpacing)
    }
}


extension EventViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        DispatchQueue.main.async {
            self.updateFiltered()
            self.eventCatalog.reloadData()
        }
    }
    
    private func updateFiltered() {
        let searchText = searchController.searchBar.text!.lowercased()
        filteredEvents = allEvents.filter { (event: Event) -> Bool in
            let tabName = topTab.titleForSegment(at: topTab.selectedSegmentIndex)!
            var condition = true
            if tabName == "All Events" {
                if (shouldFilter) {
                    print(EventViewController.chosenTags)
                    condition = !event.tags.intersection(EventViewController.chosenTags).isEmpty
                    shouldFilter = false
                }
            }
            else if tabName == "Recommended" {
                // If the current tab is 'Recommended', the current user must be logged in
                condition = !event.tags.intersection(User.current!.tags).isEmpty
            } else if tabName == "Trending" {
                // TODO: Replace with code to filter out non-trending events
            }
            
            return condition && (searchText.isEmpty || event.title.lowercased().contains(searchText) || event.eventDescription.lowercased().contains(searchText))
        }
                
        // TODO: Apply sorting algorithm depending on user settings
        filteredEvents.sort(by: { $0.title < $1.title })
    }
    
   
}
