//
// Created by Konstantin Terekhov on 11/21/17.
// Copyright (c) 2017 Konstantin Terehov. All rights reserved.
//

import Foundation
import SQLite

class MainDB {
    static let instance = MainDB()
    private let db: Connection?


    private let pointTable = Table("point")
    private let routeTable = Table("route")
    private let stopTable = Table("stop")
    private let stopTripTable = Table("stop_trip")
    private let trackTable = Table("track")
    private let tripTable = Table("trip")

    private let settingsTable = Table("settings")

    private let id = Expression<Int64>("id")
    private let trackId = Expression<Int64>("trackId")
    private let trackType = Expression<Int>("trackType")
    private let pointSort = Expression<Int>("pointSort")

    private let latitude = Expression<Float64>("latitude")
    private let longitude = Expression<Float64>("longitude")

    private let number = Expression<String>("number")
    private let name = Expression<String>("name")

    private let sortPrefix = Expression<Int64>("sortPrefix")

    private let MTStopId = Expression<Int64>("MTStopId")
    private let bearing = Expression<Int64>("bearing")
    private let busType = Expression<Bool>("busType")
    private let trolleybusType = Expression<Bool>("trolleybusType")
    private let tramType = Expression<Bool>("tramType")

    private let tripId = Expression<Int64>("tripId")
    private let stopId = Expression<Int64>("stopId")

    private let routeId = Expression<Int64>("routeId")
    private let centerLatitude = Expression<Float64>("centerLatitude")
    private let centerLongitude = Expression<Float64>("centerLongitude")

    private let endStopA = Expression<String>("endStopA")
    private let endStopB = Expression<String>("endStopB")
    private let nameA = Expression<String>("nameA")
    private let nameB = Expression<String>("nameB")


    private let lastUpdate = Expression<Int64>("lastUpdate")


    private init() {
        let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
        ).first!

        do {
            db = try Connection("\(path)/Database.sqlite3")
        } catch {
            db = nil
            print ("Unable to open database")
        }
        print ("Conected")
        createTable()
    }

    func createTable() {
        do {
            try db!.run(pointTable.create(ifNotExists: true) { table in
                table.column(id, primaryKey: true)
                table.column(trackId)
                table.column(trackType)
                table.column(pointSort)
                table.column(latitude)
                table.column(longitude)
            })
            try db!.run(pointTable.createIndex(trackId, ifNotExists: true))

            try db!.run(routeTable.create(ifNotExists: true) { table in
                table.column(id, primaryKey: true)
                table.column(number)
                table.column(name)
                table.column(sortPrefix)
            })

            try db!.run(stopTable.create(ifNotExists: true) { table in
                table.column(id, primaryKey: true)
                table.column(MTStopId)
                table.column(bearing)
                table.column(latitude)
                table.column(longitude)
                table.column(name)
            })

            try db!.run(stopTripTable.create(ifNotExists: true) { table in
                table.column(id, primaryKey: true)
                table.column(tripId)
                table.column(stopId)
            })
            try db!.run(stopTripTable.createIndex(tripId, ifNotExists: true))
            try db!.run(stopTripTable.createIndex(stopId, ifNotExists: true))

            try db!.run(trackTable.create(ifNotExists: true) { table in
                table.column(id, primaryKey: true)
                table.column(routeId)
                table.column(centerLatitude)
                table.column(centerLongitude)
            })
            try db!.run(trackTable.createIndex(routeId, ifNotExists: true))

            try db!.run(tripTable.create(ifNotExists: true) { table in
                table.column(id, primaryKey: true)
                table.column(routeId)
                table.column(endStopA)
                table.column(endStopB)
                table.column(nameA)
                table.column(nameB)
            })
            try db!.run(tripTable.createIndex(routeId, ifNotExists: true))
        } catch {
            print("Unable to create table")
        }
    }

    func hmm() {

    }
}
