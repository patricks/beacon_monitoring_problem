//
//  AppDelegate.swift
//  iBeaconProblem
//
//  Created by Patrick Steiner on 23.11.16.
//  Copyright © 2016 Mopius. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    fileprivate let locationManager = CLLocationManager()
    
    // Set you beacon uuid here
    let beaconUUID = "90dc5409-c9f4-4854-bc38-94367885850e"
    let mainRegionIdentifier = "MainRegion"
    var mainRegion: CLBeaconRegion!
    
    // using custom class, because hashable extension of CLBeacon doesn't find compare to CLBeacons via (uuid, major and minor
    var discoveredBeacons = Set<Beacon>()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        setupMainRegion()
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        stopMonitoringForAllRegions()
        
        return true
    }
    
    private func setupMainRegion() {
        let proximityUUID = UUID(uuidString: beaconUUID)
        mainRegion = CLBeaconRegion(proximityUUID: proximityUUID!, identifier: mainRegionIdentifier)
        mainRegion.notifyOnEntry = true
        mainRegion.notifyOnExit = true
        mainRegion.notifyEntryStateOnDisplay = true
    }
    
    // MARK: monitoring
    
    private func stopMonitoringForAllRegions() {
        print("Reseting all regions")
        locationManager.stopMonitoringVisits()
        locationManager.stopMonitoringSignificantLocationChanges()
        
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
    }
    
    fileprivate func startMonitoringForMainRegion() {
        print("Start monitoring for MainRegion")
        locationManager.startMonitoring(for: mainRegion)
    }
    
    fileprivate func regionFromBeacon(_ beacon: CLBeacon) -> CLBeaconRegion {
        let uuid = beacon.proximityUUID
        let major = beacon.major as CLBeaconMajorValue
        let minor = beacon.minor as CLBeaconMinorValue
        let identifier = "SubRegion-\(major)-\(minor)"
        
        return CLBeaconRegion(proximityUUID: uuid, major: major, minor: minor, identifier: identifier)
    }
    
    fileprivate func startMonitoringForRegion(beacon: CLBeacon) {
        print("Start Monitoring for SubRegion: major: \(beacon.major) minor: \(beacon.minor)")
        
        let region = regionFromBeacon(beacon)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        region.notifyEntryStateOnDisplay = true
        
        locationManager.startMonitoring(for: region)
    }
}

extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        var message = "DidChangeLocationAuthorizationState"
        
        switch status {
        case .authorizedAlways:
            message += " status: AuthorizedAlways"
            startMonitoringForMainRegion()
        case .authorizedWhenInUse:
            message += " status: AuthorizedWhenInUse"
        case .denied:
            message += " status: Denied"
        case .notDetermined:
            message += " status: Not Determined"
        case .restricted:
            message += " status: Restricted"
        }
        
        print(message)
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        var message = "DidDetermineState for region:"
        
        if let beaconRegion = region as? CLBeaconRegion {
            message = "DidDetermineState for region major: \(beaconRegion.major) minor: \(beaconRegion.minor)"
        }
        
        switch state {
        case .inside:
            message += " state: Inside"
            if region.identifier == mainRegionIdentifier {
                if let beaconRegion = region as? CLBeaconRegion {
                    print("start ranging for main region")
                    locationManager.startRangingBeacons(in: beaconRegion)
                }
            }
        case .outside:
            message += " state: Outside"
            if region.identifier == mainRegionIdentifier {
                if let beaconRegion = region as? CLBeaconRegion {
                    print("stop ranging for main region")
                    locationManager.stopRangingBeacons(in: beaconRegion)
                }
            }
        case .unknown:
            message += " state: Unknown"
        }
        
        print(message)
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        if let beaconRegion = region as? CLBeaconRegion {
            print("Start monitoring for region: major: \(beaconRegion.major) minor: \(beaconRegion.minor)")
        } else {
            print("Start monitoring for region")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("\(#function) error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Enter region \(region)")
        
        if region.identifier == mainRegionIdentifier {
            print("ENTERING MAIN REGION")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exit region \(region)")
        
        if region.identifier == mainRegionIdentifier {
            print("EXITING MAIN REGION")
        }
        
        if locationManager.monitoredRegions.count == 0 {
            startMonitoringForMainRegion()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        print("Ranged beacons count: \(beacons.count) in region: major: \(region.major) minor: \(region.minor)")
        print("Monitored regions count: \(locationManager.monitoredRegions.count) Ranged regions count: \(locationManager.rangedRegions.count)")
        
        for beacon in beacons {
            let b = Beacon(clbeacon: beacon)
            if discoveredBeacons.contains(b) {
                print("Already discovered beacon")
            } else {
                print("Adding new beacon and starting monitoring")
                discoveredBeacons.insert(b)
                startMonitoringForRegion(beacon: beacon)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        print("\(#function) error: \(error.localizedDescription)")
    }
}
