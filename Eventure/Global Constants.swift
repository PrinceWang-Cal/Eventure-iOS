//
//  Global Constants.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/5/27.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//
//  This file documents all global constants and configurations used by the app.

import UIKit
import SwiftyJSON
import Down
import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG

// MARK: - Global constants

/// The URL prefix for all the APIs
let API_BASE_URL = "https://api.eventure-app.com/"

/// Credentials: DO NOT include when committing
let USERNAME = "__replace__"
let PASSWORD = "__replace__"

let AES_KEY = "aes key"
let INTERNAL_ERROR = "internal error"
let CONNECTION_ERROR = "Connection Error"
let SERVER_ERROR = "Server Error"

let USER_DEFAULT_CRED = "CREDENTIAL"
let KEY_ACCOUNT_TYPE = "Account Type"
let ACCOUNT_TYPE_USER = "User"
let ACCOUNT_TYPE_ORG = "Org"

let URL_PREFIX = "eventure://"

/// Todo: REPLACE THIS WITH THE APP's THEME COLOR
let MAIN_TINT = UIColor(red: 1.0, green: 120/255, blue: 104/255, alpha: 1.0)
let MAIN_DISABLED = UIColor(red: 1.0, green: 179/255, blue: 168/255, alpha: 0.9)
let MAIN_TINT_DARK = UIColor(red: 230/255, green: 94/255, blue: 75/255, alpha: 1)
let LINE_TINT = UIColor.init(white: 0.9, alpha: 1)
let LINK_COLOR = UIColor(red: 104/255, green: 165/255, blue: 245/255, alpha: 1)
let WARNING_COLOR = UIColor(red: 243/255, green: 213/255, blue: 34/255, alpha: 1)
let FATAL_COLOR = UIColor(red: 224/255, green: 33/255, blue: 0, alpha: 1)
let PASSED_COLOR = UIColor(red: 155/255, green: 216/255, blue: 143/255, alpha: 1)

let MAIN_TINT6 = UIColor(red: 236/255, green: 110/255, blue: 173/255, alpha: 1.0)
let MAIN_TINT8 = UIColor(red: 255/255, green: 153/255, blue: 102/255, alpha: 1.0)

let SAMPLE_TEXT = """
[This is a Markdown Link](https://www.google.com).

**Lorem ipsum dolor sit amet**, ligula suspendisse nulla pretium, rhoncus tempor fermentum, enim integer ad vestibulum volutpat. Nisl rhoncus turpis est, vel elit, congue wisi enim nunc ultricies sit, magna tincidunt. Maecenas aliquam maecenas ligula nostra, accumsan taciti. Sociis mauris in integer, a dolor netus non dui aliquet, sagittis felis sodales, dolor sociis mauris, vel eu libero cras. Faucibus at. Arcu habitasse elementum est, ipsum purus pede porttitor class, ut adipiscing, aliquet sed auctor, imperdiet arcu per diam dapibus libero duis. Enim eros in vel, volutpat nec pellentesque leo, temporibus scelerisque nec.
### Second paragraph with heading
Ac dolor ac adipiscing amet bibendum nullam, lacus molestie ut libero nec, diam et, pharetra sodales, feugiat ullamcorper id tempor id vitae. Mauris pretium aliquet, lectus tincidunt. Porttitor mollis imperdiet libero senectus pulvinar. Etiam molestie mauris ligula laoreet, vehicula eleifend. Repellat orci erat et, sem cum, ultricies sollicitudin amet eleifend dolor nullam erat, malesuada est leo ac. Varius natoque turpis elementum est. Duis montes, tellus lobortis lacus amet arcu et. In vitae vel, wisi at, id praesent bibendum libero faucibus porta egestas, quisque praesent ipsum fermentum tempor. Curabitur auctor, erat mollis sed, turpis vivamus a dictumst congue magnis. Aliquam amet ullamcorper dignissim molestie, mollis. Tortor vitae tortor eros wisi facilisis.
"""

let PLAIN_STYLE =  """
    body {
        font-family: -apple-system;
        font-size: 17px;
        line-height: 1.5;
        letter-spacing: 1.5%;
        color: #5A5A5A;
        margin-bottom: 10px;
    }

    h1, h2, h3, h4, h5, h6 {
        font-family: -apple-system;
        font-weight: 600;
        letter-spacing: 1%;
        color: rgb(255, 120, 104);
    }

    h1 {
        font-size: 23px;
    }

    h2 {
        font-size: 22px;
    }

    h3 {
        font-size: 21px;
    }

    h4 {
        font-size: 20px;
    }

    h5 {
        font-size: 19px;
    }
    h6 {
        font-size: 18px;
    }
"""

// MARK: - Cache files

let DRAFTS_PATH = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("drafts")
let ACCOUNT_DIR = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Account", isDirectory: true)

let CURRENT_USER_PATH = ACCOUNT_DIR.path + "/" + "user"

/// Navigation bar background color
let NAVBAR_TINT = UIColor.white

/// Alpha value for disabled UI elements.
let DISABLED_ALPHA: CGFloat = 0.5

/// Custom URLSessionConfiguration with no caching
let CUSTOM_SESSION: URLSession = {
    let config = URLSessionConfiguration.default
    config.requestCachePolicy = .reloadIgnoringLocalCacheData
    config.urlCache = nil
    config.timeoutIntervalForRequest = 8.0
    return URLSession(configuration: config)
}()

/// Use this formatter to convert strings from API calls into dates and vice versa.
let DATE_FORMATTER: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US")
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    formatter.timeZone = TimeZone(abbreviation: "UTC")!
    return formatter
}()

/// A formatter to get the current year in string format.
let YEAR_FORMATTER: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy"
    formatter.locale = Locale(identifier: "en_US")
    return formatter
}()

// MARK: - Classes and Extensions

extension String {
    
    /// URL encode.
    var encoded: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
    
    /// URL decode.
    var decoded: String {
        return self.removingPercentEncoding ?? self
    }
    
    /// Email verification method.
    func isValidEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }
    
    /// Markdown-formatted text.
    func attributedText() -> NSAttributedString {
        if isEmpty { return NSAttributedString() }
        if let d = try? Down(markdownString: self).toAttributedString(.hardBreaks, stylesheet: PLAIN_STYLE) {
            return d.attributedSubstring(from: NSMakeRange(0, d.length - 1))
        } else {
            print("WARNING: markdown failed")
            return NSAttributedString(string: self, attributes: EventDetailPage.standardAttributes)
        }
    }
    
    func md5() -> String {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        let messageData = data(using:.utf8)!
        var digestData = Data(count: length)
        
        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        return digestData.map { String(format: "%02hhx", $0) }.joined()
    }
}

extension URL {
    
    /**
     Custom URL formatter.
     
     - Parameters:
        - base: The base / parent URL of the API.
        - API_Name: The API name.
        - parameters: The url parameters in the form of a Swift native dictionary.
     
     - Returns: An optional URL object (URL?) formed from the provided information.
     */
    
    static func with(base: String, API_Name: String, parameters: [String: String]) -> URL? {
        if (parameters.isEmpty) {
            return URL(string: base + API_Name)
        }
        let formattedParameters = parameters.map {
            return $0.key.encoded + "=" + $0.value.encoded
        }
        return URL(string: "\(base + API_Name)?" + formattedParameters.joined(separator: "&"))
    }
}

extension URLRequest {
    
    /// Add a basic authorization header for the current request.
    mutating func addAuthHeader() {
        let token = "\(USERNAME):\(PASSWORD)".data(using: .utf8)!.base64EncodedString()
        self.addValue("Basic \(token)", forHTTPHeaderField: "Authorization")
    }
    
    /// Add multipart data to the request.
    mutating func addMultipartBody(parameters: [String : String], files: [String: Data] = [:]) {
        
        // Build the body data
        
        let boundary = "----Eventure-API-Multipart-Boundary"
        let prefix = "--" + boundary + "\r\n"
        
        var data = Data()
        
        for parameter in parameters {
            data.append(string: prefix)
            data.append(string: "Content-Disposition: form-data; name=\"\(parameter.key)\"\r\n\r\n")
            data.append(string: parameter.value + "\r\n")
        }
        
        for file in files {
            data.append(string: prefix)
            data.append(string: "Content-Disposition: form-data; name=\"\(file.key)\"; filename=\"temp\"\r\n")
            data.append(string: "Content-Type: application/octet-stream\r\n\r\n")
            data.append(file.value)
            data.append(string: "\r\n")
        }
        
        data.append(string: "--" + boundary + "--")
        
        // Begin mutating the request
        self.addValue("multipart/form-data; charset=utf-8; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        self.httpBody = data
    }
}

extension UIView {
    
    /// Extension method that finds the optimal height for the view, given its current width.
    func preferredHeight(width: CGFloat) -> CGFloat {
        let widthConstraint = self.widthAnchor.constraint(equalToConstant: width)
        widthConstraint.priority = .init(999)
        self.addConstraint(widthConstraint)
        let height = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        self.removeConstraint(widthConstraint)
        return height
    }
}


extension UITextField {
    func doInset() {
        let inset = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.frame.height))
        self.leftView = inset
        self.leftViewMode = .always
    }
}

extension UITextView {
    func doInset() {
        self.textContainerInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    }
    
    func preferredHeight() -> CGFloat {
        let widthConstraint = self.widthAnchor.constraint(equalToConstant: frame.width)
        widthConstraint.priority = .init(999)
        self.addConstraint(widthConstraint)
        return contentSize.height
    }
}

extension Data {
    mutating func append(string: String) {
        let data = string.data(using: .utf8)!
        append(data)
    }
}

extension UIImage {
    func fixedOrientation() -> UIImage {
        if imageOrientation == .up {
            return self
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: .pi)
            break
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: -.pi / 2)
            break
        case .up, .upMirrored:
            break
        }
        switch imageOrientation {
        case UIImageOrientation.upMirrored, UIImageOrientation.downMirrored:
            transform.translatedBy(x: size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
        case UIImageOrientation.leftMirrored, UIImageOrientation.rightMirrored:
            transform.translatedBy(x: size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case UIImageOrientation.up, UIImageOrientation.down, UIImageOrientation.left, UIImageOrientation.right:
            break
        }
        
        let ctx: CGContext = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        ctx.concatenate(transform)
        
        switch imageOrientation {
        case UIImageOrientation.left, UIImageOrientation.leftMirrored, UIImageOrientation.right, UIImageOrientation.rightMirrored:
            ctx.draw(self.cgImage!, in: CGRect(origin: CGPoint.zero, size: size))
        default:
            ctx.draw(self.cgImage!, in: CGRect(origin: CGPoint.zero, size: size))
            break
        }
        
        let cgImage: CGImage = ctx.makeImage()!
        
        return UIImage(cgImage: cgImage)
    }
    
    
    func sizeDown(maxWidth: CGFloat = 500.0) -> UIImage {
        
        /*
        var currentQuality: CGFloat = 1.0
        var currentData = jpegData(compressionQuality: 1.0)
        
        while (currentData?.count ?? 0 && currentQuality > 0.01) > 200000 {
            currentQuality *= 0.85
            currentData = jpegData(compressionQuality: currentQuality)
        }*/
        
        if size.width > maxWidth {
            let newSize = CGSize(width: maxWidth, height: maxWidth / size.width * size.height)
            let renderer = UIGraphicsImageRenderer(size: newSize)
            return renderer.image { context in
                self.draw(in: CGRect(origin: .zero, size: newSize))
            }
        }
        
        return self
    }
}

/// Documents directory URL.
let DOCUMENTS_URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

/// Cache directory URL.
let CACHES = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]


// MARK: - Standard alerts

func serverMaintenanceError(vc: UIViewController, handler: (() -> ())? = nil) {
    let alert = UIAlertController(title: "Expected Error", message: "Oops, looks like our server is unavailable or under maintenance. We're very sorry for the inconvenience and we hope that you will come back later.", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
        action in
        DispatchQueue.main.async {
            handler?()
        }
    }))
    
    vc.present(alert, animated: true, completion: nil)
}

func internetUnavailableError(vc: UIViewController, handler: (() -> ())? = nil) {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
    alert.title = "Unable to Connect"
    alert.message = "Please check your internet connection."
    alert.addAction(.init(title: "OK", style: .default, handler: {
        action in
        DispatchQueue.main.async {
            handler?()
        }
    }))
    vc.present(alert, animated: true, completion: nil)
}

// MARK: - Notifications
let USER_SYNC_SUCCESS = Notification.Name("user sync success")
let USER_SYNC_FAILED = Notification.Name("user sync failed")
let ORG_SYNC_SUCCESS = Notification.Name("org sync success")
let ORG_SYNC_FAILED = Notification.Name("org sync failed")
