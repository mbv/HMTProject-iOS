//
//  MTApiHelper.swift
//  HMTProject
//
//  Created by Konstantin Terekhov on 8/29/17.
//  Copyright © 2017 Konstantin Terehov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class MTApiHelper: initializerUser {
    private let USER_AGENT = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.0147.211 Safari/537.36"
    private var sessionManager: SessionManager
    private var configurationSessionManager: URLSessionConfiguration
    private var token: String?

    private let COOKIE_EXPIRES_TIME = TimeInterval(60 * 60 * 24 * 365)
    private let COOKIE_PATH = "minsktrans.by"
    private let URL_ORIGIN = "http://minsktrans.by"

    public let URL_INDEX = "http://minsktrans.by/lookout_yard/Home/Index"
    public let URL_VEHICLES = "http://minsktrans.by/lookout_yard/Data/Vehicles"
    public let URL_SCHEDULE = "http://minsktrans.by/lookout_yard/Data/Schedule"
    public let URL_SCOREBOARD = "http://minsktrans.by/lookout_yard/Data/Scoreboard"

    private let PARAM_TOKEN = "__RequestVerificationToken"


    init() {
        var defaultHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        defaultHeaders["User-Agent"] = USER_AGENT

        configurationSessionManager = URLSessionConfiguration.default
        configurationSessionManager.httpAdditionalHeaders = defaultHeaders

        sessionManager = Alamofire.SessionManager(configuration: configurationSessionManager)
    }

    func initUser(token: String, cookies: [String: String]) {
        self.token = token

        for (key, value) in cookies {
            setCookie(cookieStorage: configurationSessionManager.httpCookieStorage, key: key, value: value)
        }
    }

    func GetData(url:String, parameters: Parameters) {
        var localParameters = parameters

        localParameters[PARAM_TOKEN] = token

        let headers: HTTPHeaders = [
            "Referer": URL_INDEX,
            "Origin": URL_ORIGIN,
            "Cache-Control": "no-cache",
        ]

        sessionManager.request(url, method: .post, parameters: localParameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print("JSON: \(json)")
            case .failure(let error):
                print(response)
                print(error)
            }
        }
    }


    private func setCookie(cookieStorage: HTTPCookieStorage?, key: String, value: String) {
        let cookieProps: [HTTPCookiePropertyKey: Any] = [
            HTTPCookiePropertyKey.domain: COOKIE_PATH,
            HTTPCookiePropertyKey.path: "/",
            HTTPCookiePropertyKey.name: key,
            HTTPCookiePropertyKey.value: value,
            HTTPCookiePropertyKey.expires: NSDate(timeIntervalSinceNow: COOKIE_EXPIRES_TIME)
        ]

        if let cookie = HTTPCookie(properties: cookieProps) {
            cookieStorage?.setCookie(cookie)
        }
    }
}


protocol initializerUser {
    func initUser(token: String, cookies: [String: String])
}