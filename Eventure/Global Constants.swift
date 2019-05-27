//
//  Global Constants.swift
//  Eventure
//
//  Created by Jia Rui Shan on 2019/5/27.
//  Copyright © 2019 UC Berkeley. All rights reserved.
//
//  This file documents all global constants used by the app

import UIKit

/// The URL prefix for all the APIs
let API_BASE_URL = "https://api.caleventbrite-test.tk"

/// Todo: REPLACE THIS WITH THE APP's THEME COLOR
let MAIN_TINT = UIColor(red: 0.5, green: 0.7, blue: 0.92, alpha: 1)

/// Todo: REPLACE THIS WITH THE NAVIGATION BAR COLOR
let NAVBAR_TINT = UIColor(white: 0.93, alpha: 1)

/// Custom URLSessionConfiguration with no caching
let CUSTOM_SESSION: URLSession = {
    let config = URLSessionConfiguration.default
    config.requestCachePolicy = .reloadIgnoringLocalCacheData
    config.urlCache = nil
    config.timeoutIntervalForRequest = 5.0
    print("setup")
    return URLSession(configuration: config)
}()
