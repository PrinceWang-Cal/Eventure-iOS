//
//  EventImagePickerCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/27.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class EventImagePickerCell: UITableViewCell {
    
    private var bgView: UIView!
    private var titleLabel: UILabel!
    private var indicator: UIImageView!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        bgView = {
            let view = UIView()
            view.backgroundColor = .white
            view.layer.cornerRadius = 7
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            
            view.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
            view.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
            view.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
            
            let bottomConstraint = view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -5)
            bottomConstraint.priority = .defaultHigh
            bottomConstraint.isActive = true
            
            return view
        }()
        
        titleLabel = {
            let label = UILabel()
            label.text = "Cover Image:"
            label.font = .systemFont(ofSize: 17, weight: .medium)
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 15).isActive = true
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            return label
        }()
        
        indicator = {
            let iv = UIImageView(image: #imageLiteral(resourceName: "disclosure_indicator").withRenderingMode(.alwaysTemplate))
            iv.tintColor = .lightGray
            iv.alpha = DISABLED_ALPHA
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(iv)
            
            iv.widthAnchor.constraint(equalToConstant: 22).isActive = true
            iv.heightAnchor.constraint(equalToConstant: 22).isActive = true
            iv.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            iv.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -10).isActive = true
            
            return iv
        }()
        
    }
    
    func expand() {
        UIView.animate(withDuration: 0.2) {
            self.indicator.transform = CGAffineTransform(rotationAngle: .pi / 2)
        }
    }
    
    func collapse() {
        UIView.animate(withDuration: 0.2) {
            self.indicator.transform = CGAffineTransform(rotationAngle: 0)
        }
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        bgView.backgroundColor = highlighted ? UIColor(white: 0.97, alpha: 1) : .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}