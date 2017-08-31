//
// Created by Konstantin Terekhov on 8/30/17.
// Copyright (c) 2017 Konstantin Terehov. All rights reserved.
//

import Foundation
import SwiftyJSON
import SocketIO

class ServerCommunication {

    private let SERVER_URL = "https://hmt.mbv-soft.ru"

    private let COMMAND_UPDATED_USER_DATA = "updated_user_data"
    private let COMMAND_UPDATED_DATA = "updated_data"
    private let COMMAND_OPERATION_DATA = "operation_data"

    var socket: SocketIOClient

    var initializerUser: InitializerUser?
    var storage: Storage?
    var operationExecutor: OperationExecutor?

    init() {
        socket = SocketIOClient(socketURL: URL(string: SERVER_URL)!, config: [.log(true), .compress])
    }

    func initialize() {
        socket.on(clientEvent: .connect) { data, ack in
            self.onConnected()
        }

        socket.on(COMMAND_UPDATED_USER_DATA) { data, ack in
            self.onUpdatedUserData(data: parseResultToJson(data: data))
        }

        socket.on(COMMAND_UPDATED_DATA) { data, ack in
            self.onUpdatedData(data: parseResultToJson(data: data))
        }

        socket.on(COMMAND_OPERATION_DATA) { data, ack in
            self.onOperationData(data: parseResultToJson(data: data))
        }
    }

    private func onConnected() {
        let json = JSON([
            "type": "iOS",
            "id": UIDevice.current.identifierForVendor!.uuidString
        ])

        if let data = json.rawString() {
            self.socket.emit("initClient", data)
        }
    }

    private func onUpdatedUserData(data: JSON?) {
        if !data {
            return
        }

        let token = data["Token"].String
        var cookies: [String: String] = []
        for (_, subJson): (String, JSON) in json["Cookies"] {
            let key = subJson["Key"].String
            let value = subJson["Value"].String
            cookies[key] = value
        }

        initializerUser.initUser(token: token, cookies: cookies)
    }

    private func onUpdatedData(data: JSON?) {
        if !data {
            return
        }
        storage.update(data: data)
    }

    func onOperationData(data: JSON?) {
        if !data {
            return
        }
        operationExecutor.execute(data: data)
    }

    private func parseResultToJson(data: [Any]) -> JSON? {
        if let rawStringData = data[0] as? String {
            let json = JSON(data: rawStringData.data(using: String.Encoding.utf8)!)

            return json
        }
    }
}
