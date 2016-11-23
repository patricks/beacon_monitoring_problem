# beacon_monitoring_problem

Since iOS 10 there is a problem with the `didExitRegion` delegate.

## Steps to reproduce

* Build the Xcode project
* Set the UUID from your beacon in the `AppDelegate.swift`
* Start the app on a actual device
* Turn on the beacon
* A new CLBeaconRegion is created with the given UUID and monitoring for this region is actived.
* Now turn on the iBeacon.
* The iBeacon get discovered and ranging is started for this region.
* Now the iBeacon gets discovered in the `didRangeBeacons` method and another monitoring region is created.
* Turn off the beacon
* The `didExitRegion` delegate never gets called
