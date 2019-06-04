//
//  RegisterViewController.swift
//  Eventure
//
//  Created by Xiang Li on 5/31/19.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//

import UIKit
import SwiftyJSON
/*
struct cellData {
    var blank : String
    var info : UITextField
}*/
class RegisterViewController: UITableViewController {
    let authUsr = "eventure-frontend"
    let authPswd = "MeiYouMiMa"
    var front2back = ["Email": "email", "Name": "displayedName", "Password": "password", "Gender": "gender"]
    var loginParameters = ["email": "", "displayedName": "", "password": "", "gender": "", "date": ""]
    let blanks = ["Email", "Name", "Password", "Gender"]
    var inputs : Array<UITextField?>!
    var activeField: UITextField?
    var register = UIButton(type: .system)
    var foot : UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputs = Array(repeatElement(nil, count: blanks.count))
        
        self.view.backgroundColor = .white
        let g = UISwipeGestureRecognizer(target: self, action: #selector(returnToLogin))
        g.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(g)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        setupTable()
        setupUI()
    }
    private func setupTable() {
        self.tableView.separatorStyle = .none
        self.tableView.register(RegisterCell.self, forCellReuseIdentifier: "register")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        //TODO: Resize
        foot = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 500))
        self.tableView.tableFooterView = foot
        foot.backgroundColor = .white
        
    }
    
    private func setupUI() {
        //self.tableView.tableFooterView!.addSubview(register)
        foot.addSubview(register)
        
        register.setTitle("Register", for: .normal)
        register.titleLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
        register.tintColor = .white
        register.backgroundColor = MAIN_TINT_DARK.withAlphaComponent(0.8)
        register.layer.cornerRadius = 18
        
        register.translatesAutoresizingMaskIntoConstraints = false
        register.widthAnchor.constraint(equalToConstant: 186).isActive = true
        register.heightAnchor.constraint(equalToConstant: 48).isActive = true
        register.centerXAnchor.constraint(equalTo: foot.centerXAnchor).isActive = true
        register.centerYAnchor.constraint(equalTo: foot.bottomAnchor, constant: -45).isActive = true
        
        register.addTarget(self, action: #selector(buttonLifted(_:)),
                              for: [.touchUpOutside, .touchDragExit, .touchDragExit, .touchCancel])
        register.addTarget(self,
                              action: #selector(sendRegistration),
                              for: .touchUpInside)
        register.addTarget(self, action: #selector(buttonPressed(_:)),
                              for: .touchDown)
        
    }
    @objc private func buttonPressed(_ sender: UIButton) {
        sender.setTitleColor(UIColor(white: 1, alpha: 0.7), for: .normal)
        sender.backgroundColor = MAIN_TINT_DARK.withAlphaComponent(1.0)
    }
    
    @objc private func buttonLifted(_ sender: UIButton) {
        sender.setTitleColor(.white, for: .normal)
        sender.backgroundColor = MAIN_TINT_DARK.withAlphaComponent(0.8)
    }
    
    @objc private func sendRegistration() {
        dismissKeyboard()

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd" // e.g. 2019-06-02
        df.locale = Locale(identifier: "en_US")
        let date = df.string(from: Date()) // pass this to the URL parameters
        loginParameters["date"] = date
        
        let reset = {
            self.register.setTitleColor(.white, for: .normal)
            self.register.setTitle("Register", for: .normal)
            self.register.isEnabled = true
            self.register.backgroundColor = MAIN_TINT_DARK.withAlphaComponent(0.8)
        }
        let cells = self.tableView.visibleCells as! [RegisterCell]
        
        //storing user inputs
        var shouldEnd = false
        for c in cells {
            let field = c.info
            if (field.text == nil || field.text == "") {
                shouldEnd = true
                print(front2back[c.blank.text!]! + " is empty")
                field.layer.borderColor = UIColor.magenta.cgColor
                reset()
            } else {
                loginParameters[front2back[c.blank.text!]!] = field.text
            }
        }
        if (shouldEnd) {
            return
        }
        print(loginParameters)
        //Make the URL and URL request
        let apiURL = URL.with(base: API_BASE_URL,
                              API_Name: "account/Register",
                              parameters: loginParameters)!
        var request = URLRequest(url: apiURL)
        
        let token = "\(authUsr):\(authPswd)".data(using: .utf8)!.base64EncodedString()
        request.httpMethod = "POST"
        request.addValue("Basic \(token)", forHTTPHeaderField: "Authorization")
        let task = CUSTOM_SESSION.dataTask(with: request) {
            data, response, error in
            
            DispatchQueue.main.async {
                reset()
            }
            
            guard error == nil else {
                print(error!); return
            }
            
            do {
                print(String(data: data!, encoding: .ascii)!)
                print(1)
                let result = try JSON(data: data!).dictionary
                let servermsg = result?["status"]?.rawString()
                print(servermsg!)
                if (servermsg == "success") {
                    let nextVC = MainTabBarController()
                    self.navigationController?.pushViewController(nextVC, animated: true)
                } else {
                    //UI related events belong in main thread
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Register Error", message: servermsg, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            } catch {
                print("error parsing")
            }
        }
        task.resume()
        
        
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "register") as! RegisterCell
        cell.blank.text = blanks[indexPath.row]
        //do not initialize blank or info here for it has passed the super init stage for a cell
        inputs[indexPath.row] = cell.info
        if (indexPath.row == 0) {
            cell.info.keyboardType = .emailAddress
        }
        if (indexPath.row < inputs.count - 1) {
            cell.info.returnKeyType = .next
        } else if (indexPath.row == inputs.count - 1) {
            cell.info.returnKeyType = .done
        }
        cell.info.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blanks.count
    }
    
    @objc private func returnToLogin() {
        //TODO: Use navigation controller for better animation
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func keyboardDidShow(_ notification: Notification) {
        let kbSize = ((notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey]) as! CGRect).size
        self.tableView.contentInset.bottom = kbSize.height
        self.tableView.scrollIndicatorInsets.bottom = kbSize.height
        if let textfield = activeField {
            // Determine whether additional space is needed to fully display the keyboard
            let bottomSpace = max(0, kbSize.height - self.tableView.frame.height +  textfield.frame.maxY + 8)
            self.tableView.contentOffset.y = bottomSpace
        }
    }
    @objc private func keyboardDidHide(_ notification: Notification) {
        self.tableView.contentInset = .zero
        self.tableView.scrollIndicatorInsets = .zero
        self.tableView.contentOffset.y = 0
    }
    
    @objc private func dismissKeyboard() {
        self.view.endEditing(true)
    }
}

extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.black.cgColor
        activeField = textField as UITextField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        for i in (0..<inputs.count) {
            if (textField == inputs[i] && i < inputs.count - 1) {
                inputs[i + 1]?.becomeFirstResponder()
                //you have to return true here since otherwise
                //it would continue the for loop and
                //either dismiss or assign the wrong first reponder
                return true
            } else {
                self.dismissKeyboard()
            }
        }
        return true
    }
}

class regLabel : UILabel {
    override open func draw(_ rect: CGRect) {
        let inset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        self.drawText(in: rect.inset(by: inset))
    }
}