//
//  TicketCenter.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/9/18.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit

class TicketCenter: UITableViewController {
    
    private var detailPage: EventDetailPage!
    private let rc = UIRefreshControl()
    
    /// Only a copy of the actual data stored in `detailPage.event`.
    var admissionTypes = [AdmissionType]()
    
    private var emptyLabel: UILabel!
    private var loadingBG: UIView!
    
    private var EMPTY_PROMPT = "No ticket types have been configured. Please go to **Event** → **Edit** → **Manage tickets** to configure them."
    
    required init(parentVC: EventDetailPage) {
        super.init(nibName: nil, bundle: nil)
        
        self.detailPage = parentVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Ticket Center"
        view.backgroundColor = EventDraft.backgroundColor
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.contentInset.top = 6
        tableView.contentInset.bottom = 6
        tableView.register(TicketTypeCell.classForCoder(), forCellReuseIdentifier: "ticket type")
        
        emptyLabel = {
            let label = UILabel()
            label.textColor = .gray
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
            label.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -30).isActive = true
            label.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
            
            return label
        }()
        
        loadingBG = view.addLoader()
        loadingBG.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        loadingBG.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        rc.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        updateQuantities()
    }
    
    @objc private func refresh() {
        updateQuantities(pulled: true)
    }
    
    private func updateQuantities(pulled: Bool = false) {
        
        emptyLabel.text = ""
        
        if !pulled {
            loadingBG.isHidden = false
        }
        
        detailPage.event.updateTicketQuantities { success in
            
            if pulled {
                self.rc.endRefreshing()
            } else {
                self.tableView.refreshControl = self.rc
                self.loadingBG.isHidden = true
            }
            
            guard success else {
                self.emptyLabel.text = CONNECTION_ERROR
                return
            }
            
            
            self.admissionTypes = self.detailPage.event.admissionTypes
            
            if self.admissionTypes.isEmpty {
                self.emptyLabel.attributedText = self.EMPTY_PROMPT.attributedText()
                self.emptyLabel.textColor = .gray
            }
            
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return admissionTypes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ticket type", for: indexPath) as! TicketTypeCell
        
        let type = admissionTypes[indexPath.row]
        cell.titleLabel.text = type.typeName
        cell.subtitleLabel.text = "Quantity sold:"
        
        let quantityDescription = type.quantitySold != nil ? String(type.quantitySold!) : "?"
        if let quota = type.quota {
            cell.valueLabel.text = quantityDescription + " / \(quota)"
        } else {
            cell.valueLabel.text = quantityDescription
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let vc = TicketManagerMain(event: detailPage.event, admissionType: admissionTypes[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
 

}
