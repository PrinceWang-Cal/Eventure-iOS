//
//  DraftLocationCell.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/8/25.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class DraftLocationCell: UITableViewCell, UITextViewDelegate {

    private var bgView: UIView!
    private(set) var promptLabel: UILabel!
    private(set) var valueText: UITextView!
    private var placeholder: UILabel!
    private var baseline: UIView!
    
    var textChangeHandler: ((UITextView) -> ())?
    
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
            view.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 6).isActive = true
            let bottomConstraint = view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -6)
            bottomConstraint.priority = .defaultHigh
            bottomConstraint.isActive = true
            
            return view
        }()
        
        promptLabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 17, weight: .medium)
            label.text = "Location:"
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            
            label.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 15).isActive = true
            label.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 15).isActive = true
            
            return label
        }()
        
        valueText = {
            let tv = UITextView()
            tv.font = .systemFont(ofSize: 17)
            tv.isScrollEnabled = false
            tv.delegate = self
            tv.backgroundColor = .clear
            tv.keyboardDismissMode = .onDrag
            tv.autocorrectionType = .no
        
            tv.textContainer.lineFragmentPadding = 0
            
            let pStyle = NSMutableParagraphStyle()
            pStyle.lineSpacing = 4
            
            tv.typingAttributes = [
                NSAttributedString.Key.paragraphStyle: pStyle,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17),
                NSAttributedString.Key.foregroundColor: MAIN_TINT_DARK
            ]
            tv.translatesAutoresizingMaskIntoConstraints = false
            addSubview(tv)
            
            tv.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 15).isActive = true
            tv.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -15).isActive = true
            tv.topAnchor.constraint(equalTo: promptLabel.bottomAnchor, constant: 4).isActive = true
            tv.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -10).isActive = true
            
            return tv
        }()
        
        placeholder = {
            let label = UILabel()
            label.numberOfLines = 10
            label.text = "TBA"
            label.translatesAutoresizingMaskIntoConstraints = false
            insertSubview(label, belowSubview: valueText)
            
            label.leftAnchor.constraint(equalTo: valueText.leftAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: valueText.rightAnchor).isActive = true
            label.topAnchor.constraint(equalTo: valueText.topAnchor, constant: 8).isActive = true
            label.bottomAnchor.constraint(lessThanOrEqualTo: valueText.bottomAnchor, constant: -10).isActive = true
            
            return label
        }()
        
        baseline = {
            let view = UIView()
            view.backgroundColor = LINE_TINT
            view.translatesAutoresizingMaskIntoConstraints = false
            insertSubview(view, belowSubview: valueText)
            
            view.heightAnchor.constraint(equalToConstant: 1).isActive = true
            view.leftAnchor.constraint(equalTo: valueText.leftAnchor).isActive = true
            view.rightAnchor.constraint(equalTo: valueText.rightAnchor).isActive = true
            view.topAnchor.constraint(equalTo: valueText.bottomAnchor).isActive = true
            
            return view
        }()
        
        
    }
    
    func setPlaceholder(string: String) {
        placeholder.attributedText = string.attributedText(style: COMPACT_STYLE)
        placeholder.textColor = .init(white: 0.8, alpha: 1)
        placeholder.font = .systemFont(ofSize: 17)
    }

    func textViewDidChange(_ textView: UITextView) {
        textChangeHandler?(textView)
        placeholder.isHidden = !textView.text.isEmpty
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
