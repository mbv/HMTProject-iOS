//
// Created by Konstantin Terekhov on 11/21/17.
// Copyright (c) 2017 Konstantin Terehov. All rights reserved.
//

import Foundation
import SQLite

class MainDB {
    static let instance = MainDB()
    private let db: Connection?


    private let contacts = Table("contacts")
    private let id = Expression<Int64>("id")
    private let name = Expression<String?>("name")
    private let phone = Expression<String>("phone")
    private let address = Expression<String>("address")


    private init() {
        let path = NSSearchPathForDirectoriesInDomains(
                .DocumentDirectory, .UserDomainMask, true
        ).first!

        do {
            db = try Connection("\(path)/Database.sqlite3")
        } catch {
            db = nil
            print ("Unable to open database")
        }

        createTable()
    }

    func createTable() {
        do {
            try db!.run(contacts.create(ifNotExists: true) { table in
                table.column(id, primaryKey: true)
                table.column(name)
                table.column(phone, unique: true)
                table.column(address)
            })
        } catch {
            print("Unable to create table")
        }
    }

    func hmm() {

    }
}
