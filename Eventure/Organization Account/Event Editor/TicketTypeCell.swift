//
//  TicketTypeCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/17.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class TicketTypeCell: UITableViewCell {
    
    private var bgView: UIView!
    private(set) var titleLabel: UILabel!
    private(set) var subtitleLabel: UILabel!
    private(set) var valueLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = .clear
        
        bgView = {
            let view = UIView()
            view.backgroundColor = .white
            view.layer.cornerRadius = 7
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            
            view.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
            view.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
            view.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
            
            let bottomConstraint = view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8)
            bottomConstraint.priority = .defaultHigh
            bottomConstraint.isActive = true
            
            return view
        }()
        
        titleLabel = {
            let label = UILabel()
            label.numberOfLines = 10
            label.font = .systemFont(ofSize: 18, weight: .semibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 15).isActive = true
            label.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -15).isActive = true
            label.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 15).isActive = true
            
            return label
        }()
        
        subtitleLabel = {
            let label = UILabel()
            label.textColor = .gray
            label.text = "Price per ticket:"
            label.font = .systemFont(ofSize: 16)
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: titleLabel.leftAnchor).isActive = true
            label.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
            label.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -15).isActive = true
            
            return label
        }()
        
        valueLabel = {
            let label = UILabel()
            label.textAlignment = .right
            label.textColor = .darkGray
            label.font = .systemFont(ofSize: 16)
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.rightAnchor.constraint(equalTo: titleLabel.rightAnchor).isActive = true
            label.topAnchor.constraint(equalTo: subtitleLabel.topAnchor).isActive = true
            
            return label
        }()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        bgView.backgroundColor = highlighted ? .init(white: 0.96, alpha: 1) : .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
