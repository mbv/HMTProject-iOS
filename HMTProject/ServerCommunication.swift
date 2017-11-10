//
// Created by Konstantin Terekhov on 8/30/17.
// Copyright (c) 2017 Konstantin Terehov. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class ServerCommunication {

    private let SERVER_URL = "https://hmt.mbv-soft.ru"

    private let COMMAND_UPDATED_USER_DATA = "updated_user_data"
    private let COMMAND_UPDATED_DATA = "updated_data"
    private let COMMAND_OPERATION_DATA = "operation_data"
    
    var apiHelper : MTApiHelper = MTApiHelper.init()



    var initializerUser: InitializerUser?
    var storage: Storage?
    var operationExecutor: OperationExecutor?

    init() {

    }

    func initialize() {
        
    }

    func getParams() {
        let params:Parameters = [
            "type": "iOS",
            "uid": UIDevice.current.identifierForVendor!.uuidString,
            "requests": [
                [
                    "type": "Vehicle",
                    "params": [
                        "city": "minsk",
                        "transportType": "bus",
                        "route": "100"
                    ]
                ]
            ]
        ]
        Alamofire.request("http://localhost:5000/request", method: .post, parameters: params, encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    var cookies: [String:String] = [:]
                    for (_,cookie):(String, JSON) in json["Cookies"] {
                        cookies[cookie["Name"].string!] = cookie["Value"].string
                    }
                    self.apiHelper.initUser(cookies: cookies)
                    for (_,request):(String, JSON) in json["Requests"] {
                        self.apiHelper.GetData(url: request["Url"].string!, parameters: request["Params"].dictionaryObject!)
                    }
                case .failure(let error):
                    print(response)
                    print(error)
                }
                
        }
    }

    private func onUpdatedUserData(data: JSON?) {


        //let token = data?["Token"].String
        //var cookies: [String: String] = [:]
        //for (_, subJson): (String, JSON) in (data?["Cookies"])! {
            //let key = subJson["Key"].String
            //let value = subJson["Value"].String
            //cookies[key] = value
        //}

        //initializerUser.initUser(token: token, cookies: cookies)
    }

    private func onUpdatedData(data: JSON?) {

    }


    private func parseResultToJson(data: [Any]) -> JSON? {
        /*if let rawStringData = data[0] as? String {
            let json = JSON(data: rawStringData.data(using: String.Encoding.utf8)!)

            return json
        }*/
        return nil
    }
}
