//
//  ExpoViewOverlay.swift
//  LavitaMap
//
//  Created by Admin on 18/08/15.
//  Copyright © 2015 Lavita. All rights reserved.
//

import UIKit
import MapKit

class ExpoOverlay: NSObject, MKOverlay {
    
    var coordinate: CLLocationCoordinate2D
    var boundingMapRect: MKMapRect
    
    init(expo: Expo) {
        boundingMapRect = expo.overlayBoundingMapRect
        coordinate = expo.midCoordinate
    }
    func canReplaceMapContent() -> Bool {
        return true
    }
}