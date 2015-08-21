//
//  GridTileOverlayRenderer.swift
//  LavitaMap
//
//  Created by Admin on 16/08/15.
//  Copyright © 2015 Lavita. All rights reserved.
//

import Foundation
import MapKit

class GridTileOverlayRenderer: MKTileOverlayRenderer {
    
    override func drawMapRect(mapRect: MKMapRect, zoomScale: MKZoomScale, inContext context: CGContext) {
        //NSLog("Rendering at (x,y):(%f,%f) with size (w,h):(%f,%f) zoom %f", mapRect.origin.x, mapRect.origin.y, mapRect.size.width, mapRect.size.height, zoomScale)
        let rect: CGRect = self.rectForMapRect(mapRect)
        // NSLog("CGRect: %@", NSStringFromCGRect(rect))
        //var path = MKTileOverlayPath()
        
        //let tileOverlay: MKTileOverlay = self.overlay as! MKTileOverlay
        let mapPoint = MKCoordinateForMapPoint(mapRect.origin)
        
        //path.x = Int(mapPoint.latitude) // Int(mapRect.origin.x * Double (zoomScale) / Double(tileOverlay.tileSize.width))
        //path.y = Int(mapPoint.longitude)// * Double (zoomScale) / Double(tileOverlay.tileSize.width))
        //path.z = Int(zoomScale)
        CGContextSetStrokeColorWithColor(context, UIColor.blueColor().CGColor)
        CGContextSetLineWidth(context, 1.0 / zoomScale)
        CGContextStrokeRect(context, rect)
        UIGraphicsPushContext(context)
        
        let lat = round (mapPoint.latitude * 1000) / 1000.0;
        let long = round (mapPoint.longitude * 1000) / 1000.0;
        let z = round(zoomScale)
        let text: String = "X=\(long)\nY=\(lat)\nZ=\(z)"
        text.drawInRect(rect, withAttributes: [NSFontAttributeName: UIFont.systemFontOfSize(30.0 / zoomScale), NSForegroundColorAttributeName: UIColor.blackColor()])
        UIGraphicsPopContext()
    }
}