//
//  Beacon.swift
//  iBeaconProblem
//
//  Created by Patrick Steiner on 23.11.16.
//  Copyright © 2016 Mopius. All rights reserved.
//

import Foundation
import CoreLocation

class Beacon {
    
    var uuid: String
    var major: Int
    var minor: Int
    
    init(uuid: String, major: Int, minor: Int) {
        self.uuid = uuid
        self.major = major
        self.minor = minor
    }
    
    init(clbeacon: CLBeacon) {
        self.uuid = clbeacon.proximityUUID.uuidString
        self.major = clbeacon.major.intValue
        self.minor = clbeacon.minor.intValue
    }
}

extension Beacon: Hashable {
    var hashValue: Int {
        return uuid.hashValue ^ major.hashValue ^ minor.hashValue
    }
    
    static func == (lhs: Beacon, rhs: Beacon) -> Bool {
        return
            lhs.uuid == rhs.uuid &&
            lhs.major == rhs.major &&
            lhs.minor == rhs.minor
    }
}
