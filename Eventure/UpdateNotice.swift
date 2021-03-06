//
//  UpdateNotice.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/12.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class UpdateNotice: UIViewController {
    
    private var logo: UIImageView!
    private var titleLabel: UILabel!
    private var subtitleLabel: UILabel!
    private var updateButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        
        logo = {
            let iv = UIImageView(image: #imageLiteral(resourceName: "user_default"))
            iv.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(iv)
            
            iv.widthAnchor.constraint(equalToConstant: 100).isActive = true
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            iv.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 65).isActive = true
            iv.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            
            return iv
        }()
        
        titleLabel = {
            let label = UILabel()
            label.text = "Update Notice"
            label.font = .systemFont(ofSize: 25, weight: .semibold)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 22).isActive = true
            label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            
            return label
        }()
        
        subtitleLabel = {
            let label = UILabel()
            label.numberOfLines = 0
            label.attributedText = "We've made some major changes to our platform, and we are sorry to let you know that this version of Eventure is **no longer supported**. Please go to the App Store to download the latest version.".attributedText(style: COMPACT_STYLE)
            label.textAlignment = .center
            label.textColor = .gray
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15).isActive = true
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 35).isActive = true
            label.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -35).isActive = true
            
            return label
        }()

        updateButton = {
            let button = UIButton(type: .system)
            button.tintColor = .white
            button.setTitle("Update", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
            button.backgroundColor = MAIN_TINT
            button.layer.cornerRadius = 10
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
            
            button.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            button.widthAnchor.constraint(greaterThanOrEqualToConstant: 220).isActive = true
            button.heightAnchor.constraint(equalToConstant: 53).isActive = true
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -65).isActive = true
            
            button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
            
            return button
        }()
    }
    
    @objc private func buttonPressed() {
        UIApplication.shared.open(URL(string: APP_STORE_LINK)!, options: [:], completionHandler: nil)
    }

}
