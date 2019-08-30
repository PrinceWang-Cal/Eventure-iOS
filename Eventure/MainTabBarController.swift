//
//  MainTabBarController.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/5/26.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON

class MainTabBarController: UITabBarController {
    
    static var current: MainTabBarController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        view.tintColor = MAIN_TINT
    }
    
    func loadSupportedCampuses() {
        
        if !Event.supportedCampuses.isEmpty { return }
        
        let url = URL(string: API_BASE_URL + "account/Campuses")!
        var request = URLRequest(url: url)
        request.addAuthHeader()
        
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            guard error == nil else {
                return
            }
            
            if let json = try? JSON(data: data!).arrayValue {
                for campus in json {
                    if let name = campus.dictionary?["Name"]?.string, let suffix = campus.dictionary?["Email suffix"]?.string {
                        Event.supportedCampuses[name] = suffix
                    }
                }
                print("supported campuses: \(Event.supportedCampuses.values)")
            } else {
                print(String(data: data!, encoding: .utf8)!)
            }
        }
        
        task.resume()
    }
    
    func checkForNotices() {
        /*
        let alert = UIAlertController(
            title: "Server Notice",
            message: String(data: data!, encoding: .utf8),
            preferredStyle: .alert)
        alert.addAction(.init(title: "Dismiss", style: .cancel, handler: { action in
            
        }))
        self.present(alert, animated: true, completion: nil)*/
    }
    
    private func setupUserTabs() {
                
        let tab1 = EventViewController()
        tab1.tabBarItem = UITabBarItem(title: "Events", image: #imageLiteral(resourceName: "search"), tag: 0)

        let tab2 = OrganizationsViewController()
        tab2.tabBarItem = UITabBarItem(title: "Organizations", image: #imageLiteral(resourceName: "organization"), tag: 1)
        
        let tab3 = AccountViewController()
        tab3.tabBarItem = UITabBarItem(title: "Me", image: #imageLiteral(resourceName: "home"), tag: 2)
        
        
        viewControllers = [tab1, tab2, tab3].map {
            let nav = UINavigationController(rootViewController: $0)
            
            /// REPLACE
            nav.navigationBar.barTintColor = NAVBAR_TINT
         
            return nav
        }
    }
    
    private func setupOrganizationTabs() {
        
        tabBar.tintColor = MAIN_TINT
        
        let tab1 = OrgEventViewController()
        tab1.tabBarItem = UITabBarItem(title: "Event Posts", image: #imageLiteral(resourceName: "post"), tag: 0)
        
        let tab2 = AccountViewController()
        tab2.tabBarItem = UITabBarItem(title: "Account Settings", image: #imageLiteral(resourceName: "settings"), tag: 1)
    
        viewControllers = [tab1, tab2].map {
            let nav = UINavigationController(rootViewController: $0)
            /// REPLACE
            nav.navigationBar.barTintColor = NAVBAR_TINT
            
            return nav
        }
    }
    
    /// Should be called when user finished login.
    func openScreen(isUserAccount: Bool = true) {
        if isUserAccount {
            print("Logged in as '" + (User.current?.displayedName ?? "guest") + "'")
            setupUserTabs()
            if User.current != nil {
                selectedIndex = 0
                UserDefaults.standard.set(ACCOUNT_TYPE_USER, forKey: KEY_ACCOUNT_TYPE)
            } else {
                UserDefaults.standard.removeObject(forKey: KEY_ACCOUNT_TYPE)
            }
        } else {
            print("Logged in as organization '\(Organization.current?.title ?? "unknown")'")
            selectedIndex = 0
            setupOrganizationTabs()
            UserDefaults.standard.set(ACCOUNT_TYPE_ORG, forKey: KEY_ACCOUNT_TYPE)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func loginSetup() {
        
        loadSupportedCampuses()
        checkForNotices()
        
        if let type = UserDefaults.standard.string(forKey: KEY_ACCOUNT_TYPE) {
            if type == ACCOUNT_TYPE_ORG, let current = Organization.cachedOrgAccount(at: CURRENT_USER_PATH) {
                Organization.current = current
                User.current = nil
                openScreen(isUserAccount: false)
            } else {
                User.current = User.cachedUser(at: CURRENT_USER_PATH)
                Organization.current = nil
                openScreen(isUserAccount: true)
            }
        } else {
            // Login as guest
            openScreen()
        }
        
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
