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

var sessionManager: SessionManager?

func GetData() {
    var defaultHeaders = Alamofire.SessionManager.defaultHTTPHeaders
    defaultHeaders["User-Agent"] = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.0147.211 Safari/537.36"
    
    let configuration = URLSessionConfiguration.default
    configuration.httpAdditionalHeaders = defaultHeaders
    setCookie(cookieStorage: configuration.httpCookieStorage, key: "ASP.NET_SessionId", value: "5l5n3weysulx2k5gjvlmg3ed")
    setCookie(cookieStorage: configuration.httpCookieStorage, key: "__RequestVerificationToken_L2xvb2tvdXRfeWFyZA2", value: "Cqqwm6m6sx6LUQd9kyEWdN5lmfUVrs2lI2Dtw2OJP11xZraThi5_x9mRhRtjw80vcKQg9QVGnOp1TwoGCYBFmKLqYY0OpY97k7JJp4KcOqs1")
    setCookie(cookieStorage: configuration.httpCookieStorage, key: ".AspNet.ApplicationCookie", value: "vwluDkev0VSIc0V8-f-_Uq0a_h0H2mRRMSsB6219bV2nXqjlF7b_UhOgzYoTqLelM_HAuVzrdXwVSWAzXmUTdrX432YojpbPdV9GLwXiD22G-04G7-iicaFJgmHRQBTNLPJXmOVg-i6lNI-JDNCoJTWS4P1muGhpTP3F2ryQNQzmZHypU0rsvAgX0VfpmgTkhC8d17h9QrqkcW04VBhOkylHaCKX2TLsHcSPtoMudDW-8biPUDjUAbQtELG5JtPBob066mCjz4HiFiDRWSl1IPocAyDAzoyWOH4R8Kqf0F5JBF10CAgsscvyJ-3PzLmnHVagXCGfQSEojwzNCzkYynsyE_oxqPo76fTRkCf0z8lfLhu8en0Hbk52QAF1b7sI98edNDpBLLmforuBi927s_gIzjuFxVC5cLlarI7RGGcAgtsmcn8R8WjbRL0TjU0VQMFn94LUHtQuJQz_-Y0kfZJ1mN9nUG2mRGcKrsLjl1osoqNu82JtGiutcTDEVXp4")
    
    sessionManager = Alamofire.SessionManager(configuration: configuration)
    
    let parameters: Parameters = [
        "__RequestVerificationToken": "iqIggO0iQ-b59WGPYF2vRj2F2zqsr3qDFFUSatLDxxxudPcPAvGoaKqE_2NVy39XhamDuQDa9zkM7kvDNtxdM1fM9wZLoMAJ-1AyG0ATQZpUaQSI-81WnYg68o3bP9XUIiaO0cMMaBqs3cKTuHgJdg2",
        "p":  "minsk",
        "tt": "bus",
        "r":  "100",
        "v": "45577",
    ]
    
    let url = "http://minsktrans.by/lookout_yard/Data/Vehicles"
    //let url = "http://httpbin.org/post"
    
    let headers: HTTPHeaders = [
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
        "Referer": "http://minsktrans.by/lookout_yard/Home/Index",
        "Origin": "http://minsktrans.by",
        "Cache-Control": "no-cache",
    ]
    
    sessionManager?.request(url, method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
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


func setCookie(cookieStorage: HTTPCookieStorage?, key: String, value: String) {
    let URL = "minsktrans.by"
    //let URL = "httpbin.org"
    let ExpTime = TimeInterval(60 * 60 * 24 * 365)
    let cookieProps: [HTTPCookiePropertyKey : Any] = [
        HTTPCookiePropertyKey.domain: URL,
        HTTPCookiePropertyKey.path: "/",
        HTTPCookiePropertyKey.name: key,
        HTTPCookiePropertyKey.value: value,
        HTTPCookiePropertyKey.expires: NSDate(timeIntervalSinceNow: ExpTime)
    ]
    
    if let cookie = HTTPCookie(properties: cookieProps) {
        cookieStorage?.setCookie(cookie)
    }
}
