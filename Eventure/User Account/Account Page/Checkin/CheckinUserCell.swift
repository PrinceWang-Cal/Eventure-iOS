//
//  CheckinUserCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/2.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class CheckinUserCell: UITableViewCell {
    
    private var bgView: UIView!
    private(set) var profilePicture: UIImageView!
    private var nameLabel: UILabel!
    private var majorLabel: UILabel!
    private var registrant: Registrant?
    private(set) var placeLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        bgView = {
            let view = UIView()
            view.backgroundColor = .white
            view.layer.cornerRadius = 8
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            
            view.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
            view.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
            view.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 6).isActive = true
            
            let bottomConstraint = view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -6)
            bottomConstraint.priority = .defaultHigh
            bottomConstraint.isActive = true
            
            return view
        }()
        
        profilePicture = {
            let iv = UIImageView(image: #imageLiteral(resourceName: "guest").withRenderingMode(.alwaysTemplate))
            iv.tintColor = MAIN_DISABLED
            iv.layer.cornerRadius = 2
            iv.layer.masksToBounds = true
            iv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(iv)
            
            iv.widthAnchor.constraint(equalToConstant: 25).isActive = true
            iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
            iv.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 15).isActive = true
            iv.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            return iv
        }()
        
        nameLabel = {
            let label = UILabel()
            label.numberOfLines = 2
            label.lineBreakMode = .byWordWrapping
            label.font = .systemFont(ofSize: 17, weight: .medium)
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: profilePicture.rightAnchor, constant: 12).isActive = true
            label.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -35).isActive = true
            label.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 10).isActive = true
            
            return label
        }()
        
        majorLabel = {
            let label = UILabel()
            label.numberOfLines = 3
            label.lineBreakMode = .byWordWrapping
            label.font = .systemFont(ofSize: 16)
            label.textColor = .gray
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: nameLabel.leftAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: nameLabel.rightAnchor).isActive = true
            label.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5).isActive = true
            label.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -10).isActive = true
            
            return label
        }()
        
        placeLabel = {
            let label = UILabel()
            label.textColor = .lightGray
            label.font = .systemFont(ofSize: 16)
            label.textAlignment = .right
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -20).isActive = true
            label.centerYAnchor.constraint(equalTo: bgView.centerYAnchor).isActive = true
            
            return label
        }()
    }
    
    
    func setup(registrant: Registrant) {
        self.registrant = registrant
        if User.current?.userID == registrant.userID {
            nameLabel.text = "(You) " + registrant.name
        } else {
            nameLabel.text = registrant.name
        }
        if nameLabel.text!.isEmpty { nameLabel.text = registrant.email }
        self.placeLabel.text = String(registrant.order)
        majorLabel.text = registrant.major.isEmpty ? "Undeclared" : registrant.major
        if registrant.profilePicture != nil {
            profilePicture.image = registrant.profilePicture
        } else {
            profilePicture.image = #imageLiteral(resourceName: "guest").withRenderingMode(.alwaysTemplate)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
