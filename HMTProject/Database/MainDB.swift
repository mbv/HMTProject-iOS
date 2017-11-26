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
    private let vehicleType = Expression<Int>("vehicleType")

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
            print("Unable to open database")
        }
        print("Conected")
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
                table.column(vehicleType)
            })

            try db!.run(stopTable.create(ifNotExists: true) { table in
                table.column(id, primaryKey: true)
                table.column(MTStopId)
                table.column(bearing)
                table.column(latitude)
                table.column(longitude)
                table.column(name)
                table.column(busType)
                table.column(trolleybusType)
                table.column(tramType)
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

    func createUpdatePoints(points: [Point]) {
        do {
            try db!.transaction {
                for point in points {
                    try db!.run(pointTable.insert(or: .replace,
                            id <- point.id!,
                            trackId <- point.trackId!,
                            trackType <- point.trackType!,
                            pointSort <- point.pointSort!,
                            latitude <- point.latitude!,
                            longitude <- point.longitude!
                    ))
                }
            }
        } catch {
            print("Unable to create update Points")
        }
    }

    func createUpdateRoutes(routes: [Route]) {
        do {
            try db!.transaction {
                for route in routes {
                    try db!.run(routeTable.insert(or: .replace,
                            id <- route.id!,
                            number <- route.number!,
                            name <- route.name!,
                            sortPrefix <- route.sortPrefix!,
                            vehicleType <- route.vehicleType!
                    ))
                }
            }
        } catch {
            print("Unable to create update Routes")
        }
    }

    func createUpdateStops(stops: [Stop]) {
        do {
            try db!.transaction {
                for stop in stops {
                    try db!.run(stopTable.insert(or: .replace,
                            id <- stop.id!,
                            MTStopId <- stop.MTStopId!,
                            bearing <- stop.bearing!,
                            latitude <- stop.latitude!,
                            longitude <- stop.longitude!,
                            name <- stop.name!,
                            busType <- stop.busType!,
                            trolleybusType <- stop.trolleybusType!,
                            tramType <- stop.tramType!
                    ))
                }
            }
        } catch {
            print("Unable to create update Stops")
        }
    }

    func createUpdateStopTrips(stopTrips: [StopTrip]) {
        do {
            try db!.transaction {
                for stopTrip in stopTrips {
                    try db!.run(stopTripTable.insert(or: .replace,
                            id <- stopTrip.id!,
                            tripId <- stopTrip.tripId!,
                            stopId <- stopTrip.stopId!
                    ))
                }
            }
        } catch {
            print("Unable to create update StopTrips")
        }
    }

    func createUpdateTracks(tracks: [Track]) {
        do {
            try db!.transaction {
                for track in tracks {
                    try db!.run(trackTable.insert(or: .replace,
                            id <- track.id!,
                            routeId <- track.routeId!,
                            centerLatitude <- track.centerLatitude!,
                            centerLongitude <- track.centerLongitude!
                    ))
                }
            }
        } catch {
            print("Unable to create update Tracks")
        }
    }

    func createUpdateTrips(trips: [Trip]) {
        do {
            try db!.transaction {
                for trip in trips {
                    try db!.run(tripTable.insert(or: .replace,
                            id <- trip.id!,
                            routeId <- trip.routeId!,
                            endStopA <- trip.endStopA!,
                            endStopB <- trip.endStopB!,
                            nameA <- trip.nameA!,
                            nameB <- trip.nameB!
                    ))
                }
            }
        } catch {
            print("Unable to create update Trips")
        }
    }

    func getStops() -> [Stop] {
        var stops = [Stop]()

        do {
            for stop in try db!.prepare(stopTable) {
                stops.append(Stop(
                        id: stop[id],
                        MTStopId: stop[MTStopId],
                        bearing: stop[bearing],
                        latitude: stop[latitude],
                        longitude: stop[longitude],
                        name: stop[name],
                        busType: stop[busType],
                        trolleybusType: stop[trolleybusType],
                        tramType: stop[tramType]
                ))
            }
        } catch {
            print("Select failed")
        }

        return stops
    }

    func getRoutesAcrossStop(stop: Stop) -> [Route] {
        var routes = [Route]()

        do {
            for route in try db!.prepare(routeTable.join(tripTable, on: routeTable[id] == tripTable[routeId]).join(stopTripTable, on: stopTripTable[tripId] == tripTable[id]).select(routeTable[*]).filter(stopTripTable[stopId] == stop.id!)) {
                routes.append(Route(
                        id: route[id],
                        number: route[number],
                        name: route[name],
                        sortPrefix: route[sortPrefix],
                        vehicleType: route[vehicleType]
                ))
            }
        } catch {
            print("Select failed: \(error)")
        }
        return routes;
    }
}
