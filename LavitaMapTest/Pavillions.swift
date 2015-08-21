//
//  Park.swift
//  Park View
//
//  Created by Niv Yahel on 2014-10-30.
//  Copyright (c) 2014 Chris Wagner. All rights reserved.
//

import UIKit
import MapKit

class Pavillions {
    
    var boudariesDictionary: [String: [CLLocationCoordinate2D]] = Dictionary()
    
    var pavillions_num : Int
    let boundaryPointsCount: Int = 4
    var name: String?
    
    init(filename: String) {
        let filePath = NSBundle.mainBundle().pathForResource(filename, ofType: "plist")
        let properties = NSDictionary(contentsOfFile: filePath!)
        
        pavillions_num = properties!["pav_num"] as! Int
        
        /*for index in 0...pavillions_num-1 {
            let pavTitle = String(index)
        }*/
        addPavByTytleToArray("Pavillion 7", properties:properties!);
        addPavByTytleToArray("Pavillion 8", properties:properties!);
        addPavByTytleToArray("Pavillion 12", properties:properties!);

    }
    
    func addPavByTytleToArray(title:String, properties:NSDictionary?) {
        
        let boundaryPoints = properties![title] as! NSArray
        
        var boundary: [CLLocationCoordinate2D]
        
        boundary = []
        for i in 0...boundaryPointsCount-1 {
            let p = CGPointFromString(boundaryPoints[i] as! String)
            boundary += [CLLocationCoordinate2DMake(CLLocationDegrees(p.x), CLLocationDegrees(p.y))]
        }
        boudariesDictionary[title] = boundary
    }
    
    func boundaryRect(pavTitle: String ) -> MKMapRect {
        
        let boundaries = boudariesDictionary[pavTitle];
        
        return MKMapRectMake(   boundaries![0].latitude,
                                boundaries![0].longitude,
            fabs(boundaries![0].latitude - boundaries![3].latitude),
            fabs(boundaries![0].longitude - boundaries![1].longitude))
        
    }
    
    func overlayBoundingMapRect(pavTitle: String ) -> MKMapRect {
        
        let boundaries = boudariesDictionary[pavTitle];
            let topLeft = MKMapPointForCoordinate(boundaries![0]);
            let topRight = MKMapPointForCoordinate(boundaries![1]);
            let bottomLeft = MKMapPointForCoordinate(boundaries![3]);
        
            return MKMapRectMake(topLeft.x,
                topLeft.y,
                fabs(topLeft.x-topRight.x),
                fabs(topLeft.y - bottomLeft.y))
        
    }
}