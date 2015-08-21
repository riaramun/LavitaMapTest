//
//  ViewController.swift
//  LavitaMap
//
//  Created by Admin on 16/08/15.
//  Copyright © 2015 Lavita. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController , MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    var pavsModel: Pavillions?
    var expoModel: Expo?
    var expoOverlay: ExpoOverlay?
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var uiGestureRecognizer = UIGestureRecognizer()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        self.mapView.rotateEnabled = false
        
        self.addPavillonsMap()
        self.addPavillons()
        self.initMapEvents()
    }
    
    /* func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    
    let pavPolygon:MKPolygon = annotation as! MKPolygon
    let pavRect = pavsModel?.overlayBoundingMapRect(pavPolygon.title!)
    let region = MKCoordinateRegionForMapRect(pavRect!)
    let rect = mapView.convertRegion(region, toRectToView: mapView)
    let annotationView = AnnotationView(frame: rect)
    
    annotationView.canShowCallout = true
    
    return annotationView
    }*/
    
    func xscale(t:CGAffineTransform) -> CGFloat {
        return sqrt(t.a * t.a + t.c * t.c)
    }
    
    func yscale(t:CGAffineTransform) -> CGFloat {
        return sqrt(t.b * t.b + t.d * t.d)
    }
    
    
    func didTapMap(gestureRecognizer: UIGestureRecognizer) {
        // Get the spot that was tapped.
        let tapPoint: CGPoint = gestureRecognizer.locationInView(mapView)
        let touchMapCoordinate: CLLocationCoordinate2D = mapView.convertPoint(tapPoint, toCoordinateFromView: mapView)
        
        let pavillion = appDelegate.cdh.fetchEntryByPoint(touchMapCoordinate)
        if pavillion != nil {
            showAnnotation(pavillion!.title)
        }
        print("\(touchMapCoordinate.latitude),\(touchMapCoordinate.longitude)")
    }
    
    func addPavillons() {
        
        let entriesCount = appDelegate.cdh.getEntriesCount()
        
        pavsModel = Pavillions(filename: "pavillions")
        let count = pavsModel?.boundaryPointsCount
        
        for (title, boundary) in pavsModel!.boudariesDictionary {
            
            var bound: [CLLocationCoordinate2D]? = boundary
            let pavPolygon = MKPolygon(coordinates: &bound!, count: count!)
            pavPolygon.title = title
            //mapView.addOverlay(pavPolygon)
            mapView.addAnnotation(pavPolygon)
            if(entriesCount==0) {
                appDelegate.cdh.saveEntry(title, pavRect: pavsModel!.boundaryRect(title))
        }
       /*for i in 0...pavsModel!.pavillions_num-1 {
            let title = String(i);
            var boundary = pavsModel?.boudariesDictionary[title]
            let count = pavsModel?.boundaryPointsCount
            let pavPolygon = MKPolygon(coordinates: &boundary!, count: count!)
            pavPolygon.title = title
            //mapView.addOverlay(pavPolygon)
            mapView.addAnnotation(pavPolygon)
            
            }*/
        }
    }
    func addPavillonsMap() {
        
        expoModel = Expo(filename: "expo_boundary")
        expoOverlay = ExpoOverlay(expo: expoModel!)
        
        //self.mapView.addGestureRecognizer(gestureRecognizer: )
        let gridOverlay = GridTileOverlay();
        
        gridOverlay.canReplaceMapContent = true;
        
        mapView.addOverlay(gridOverlay);
        
        
        let latDelta = expoModel!.overlayTopLeftCoordinate.latitude - expoModel!.overlayBottomRightCoordinate.latitude
        // think of a span as a tv size, measure from one corner to another
        let span = MKCoordinateSpanMake(fabs(latDelta), 0.0)
        let region = MKCoordinateRegionMake(expoModel!.midCoordinate, span)
        mapView.region = region
        mapView.insertOverlay(expoOverlay!, belowOverlay: gridOverlay);
        
    }
    func initMapEvents() {
        let singleTap = UITapGestureRecognizer(target: self, action: "didTapMap:")
        singleTap.delegate = self
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        
        mapView.addGestureRecognizer(singleTap)
    }
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolygon {
            let polygonView = MKPolygonRenderer(overlay: overlay)
            polygonView.strokeColor = UIColor.magentaColor()
            return polygonView
        }
        else if overlay is ExpoOverlay {
            let expoImage = UIImage(named: "exposition_plan")
            let overlayView = ExpoOverlayView(overlay: overlay, overlayImage: expoImage!)
            return overlayView
        }
            
        else if overlay is GridTileOverlay {
            let renderer = GridTileOverlayRenderer(overlay:overlay)
            //Set the renderer alpha to be overlay alpha
            renderer.alpha = (overlay as! GridTileOverlay).alpha
            
            return renderer
        }
        else if overlay is MKTileOverlay {
            return MKTileOverlayRenderer(overlay:overlay)
        }
        return MKTileOverlayRenderer()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var region:MKCoordinateRegion = MKCoordinateRegion()
    var manuallyChangingMap : Bool = false
    
    var lastGoodMapRect:MKMapRect? = nil
    
    //var myPolyline = MKPolygon ()
    
    // var oldZoomScale: CGFloat?
    func showAnnotation(title:String) {
        var annotationToShow: MKAnnotation?
        for annotation in mapView.annotations {
            if annotation.title! == title {
                annotationToShow = annotation
                break
            }
        }
        mapView.selectAnnotation(annotationToShow!, animated: true)
    }
    
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool)
    {
        
        
        //let zoomScale  =  CGFloat(self.mapView.visibleMapRect.size.width) / self.mapView.bounds.size.width;
        /*  let newZoomScale = round(CGFloat (mapView.camera.altitude)*100.000/100.000)
        let zoom = oldZoomScale!/newZoomScale
        
        let annotations = self.mapView.annotations
        for annotation: MKAnnotation in annotations {
        let annotationView: AnnotationView = self.mapView.viewForAnnotation(annotation) as! AnnotationView
        
        
        
        annotationView.transform = CGAffineTransformScale(annotationView.transform, zoom, zoom)
        
        }
        oldZoomScale = newZoomScale*/
        if lastGoodMapRect == nil {
            lastGoodMapRect = expoOverlay!.boundingMapRect
        }
        if manuallyChangingMap {
            return
        }
        let mapContainsOverlay: Bool = MKMapRectContainsRect(mapView.visibleMapRect, expoOverlay!.boundingMapRect)
        if mapContainsOverlay {
            let widthRatio: Double = expoOverlay!.boundingMapRect.size.width / mapView.visibleMapRect.size.width
            let heightRatio: Double = expoOverlay!.boundingMapRect.size.height / mapView.visibleMapRect.size.height
            if (widthRatio < 0.9) || (heightRatio < 0.9) {
                manuallyChangingMap = true
                mapView.setVisibleMapRect(expoOverlay!.boundingMapRect, animated: true)
                manuallyChangingMap = false
            }
        }
        else {
            let isIntersect = MKMapRectIntersectsRect(expoOverlay!.boundingMapRect,mapView.visibleMapRect)
            if !isIntersect {
                manuallyChangingMap = true
                mapView.setVisibleMapRect(lastGoodMapRect!, animated: true)
                manuallyChangingMap = false
            }
            else {
                lastGoodMapRect = mapView.visibleMapRect
            }
        }
    }
}

