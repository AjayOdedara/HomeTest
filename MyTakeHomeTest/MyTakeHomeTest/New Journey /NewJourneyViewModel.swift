//
//  NewJourneyViewModel.swift
//  MyTakeHomeTest
//
//  Created by Ajay Odedra on 24/03/19.
//  Copyright © 2019 Ajay Odedra. All rights reserved.
//

import Foundation
import CoreLocation


final class NewJourneyViewModel{

    var run:Run!
    
    var title: String{
        return "Journey"
    }
    
    var locationManager = LocationManager.shared
    var seconds = 0
    var timer: Timer?
    var distance = Measurement(value: 0, unit: UnitLength.meters)
    var locationList: [CLLocation] = []
    
   
    func saveRun() {
        
        let newRun = Run(context: CoreDataStack.context)
        newRun.distance = distance.value
        newRun.duration = Int16(seconds)
        newRun.timestamp = Date()
        
        for location in locationList {
            let locationObject = Location(context: CoreDataStack.context)
            locationObject.timestamp = location.timestamp
            locationObject.latitude = location.coordinate.latitude
            locationObject.longitude = location.coordinate.longitude
            newRun.addToLocations(locationObject)
        }
        
        CoreDataStack.saveContext()
        run = newRun
    }
    
}
