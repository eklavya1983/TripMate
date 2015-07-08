//
//  Trip.swift
//  TripMate
//
//  Created by Rao on 7/6/15.
//  Copyright (c) 2015 Rao. All rights reserved.
//

import Foundation

class ImageInfo {
    var id: String!
    // TODO(Rao): May need to make it something other than a string
    var localPath: String?
}

class TripEntry {
    var id: String?
    var text: String?
    var images: [ImageInfo]?
}

class Trip {
    struct Info {
        var name: String
    }
    
    init(name: String) {
        self.info = Info(name: name)
    }
    func addEntry(entry: TripEntry) {
        entries.append(entry)
    }
    func getEntry(idx: Int) -> TripEntry {
        return entries[idx]
    }
    func getEntriesCount() -> Int {
        return entries.count
    }
    
    var info: Info
    private var entries = [TripEntry]()
    private var unsyncedEntries = [TripEntry]()
}

class TripsManager {
    func addTrip(name: String) {
        var trip = Trip(name: name)
        trips.append(trip)
    }
    func getTripListSize() -> Int {
        return trips.count
    }
    func getTripInfo(index: Int) -> Trip.Info {
        return trips[index].info
    }
    func getTrip(index: Int) ->Trip {
        return trips[index]
    }
    var trips = [Trip]()
}