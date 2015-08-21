//
//  CoreDataHelper.swift
//  SwiftCoreDataSimpleDemo
//
//  Created by CHENHAO on 14-6-7.
//  Copyright (c) 2014 CHENHAO. All rights reserved.
//

import CoreData
import UIKit
import MapKit

class CoreDataHelper: NSObject{
    
    let store: CoreDataStore!
    
    override init(){
        // all CoreDataHelper share one CoreDataStore defined in AppDelegate
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.store = appDelegate.cdstore
        
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "contextDidSaveContext:", name: NSManagedObjectContextDidSaveNotification, object: nil)
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // #pragma mark - Core Data stack
    
    // Returns the managed object context for the application.
    // Normally, you can use it to do anything.
    // But for bulk data update, acording to Florian Kugler's blog about core data performance, [Concurrent Core Data Stacks – Performance Shootout](http://floriankugler.com/blog/2013/4/29/concurrent-core-data-stack-performance-shootout) and [Backstage with Nested Managed Object Contexts](http://floriankugler.com/blog/2013/5/11/backstage-with-nested-managed-object-contexts). We should better write data in background context. and read data from main queue context.
    // If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
    
    // main thread context
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.store.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // Returns the background object context for the application.
    // You can use it to process bulk data update in background.
    // If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
    
    lazy var backgroundContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.store.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var backgroundContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        backgroundContext.persistentStoreCoordinator = coordinator
        return backgroundContext
        }()
    
    
    // save NSManagedObjectContext
    func saveContext (context: NSManagedObjectContext) {
        var error: NSError? = nil
        if context.hasChanges {
            do {
                try context.save()
            } catch let error1 as NSError {
                error = error1
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
    
    func saveContext () {
        self.saveContext( self.backgroundContext! )
    }
    
    // call back function by saveContext, support multi-thread
    func contextDidSaveContext(notification: NSNotification) {
        let sender = notification.object as! NSManagedObjectContext
        if sender === self.managedObjectContext {
            NSLog("******** Saved main Context in this thread")
            self.backgroundContext!.performBlock {
                self.backgroundContext!.mergeChangesFromContextDidSaveNotification(notification)
            }
        } else if sender === self.backgroundContext {
            NSLog("******** Saved background Context in this thread")
            self.managedObjectContext!.performBlock {
                self.managedObjectContext!.mergeChangesFromContextDidSaveNotification(notification)
            }
        } else {
            NSLog("******** Saved Context in other thread")
            self.backgroundContext!.performBlock {
                self.backgroundContext!.mergeChangesFromContextDidSaveNotification(notification)
            }
            self.managedObjectContext!.performBlock {
                self.managedObjectContext!.mergeChangesFromContextDidSaveNotification(notification)
            }
        }
    }
    
    func getEntriesCount() -> Int {
        let fReq = NSFetchRequest(entityName: "Pavillion")
        var fetchResults : [Pavillion]?
        do {
            try fetchResults = managedObjectContext!.executeFetchRequest(fReq) as! [Pavillion]
        }
        catch {
        }
        return fetchResults!.count
    }
    func fetchEntryByTitle(title: String) -> Pavillion? {
        let fReq = NSFetchRequest(entityName: "Pavillion")
        fReq.predicate = NSPredicate(format: "'%@' == title", argumentArray: [title])
        var res:Pavillion?
        var fetchResults : [Pavillion]
        do {
            try fetchResults = managedObjectContext!.executeFetchRequest(fReq) as! [Pavillion]
            res = fetchResults[0]
        }
        catch {
        }
        return res
    }
    
    func fetchEntryByPoint(point: CLLocationCoordinate2D) -> Pavillion?
    {
        let x = point.latitude
        let y = point.longitude
        
        // x > x0
        let fReq = NSFetchRequest(entityName: "Pavillion")
        fReq.predicate = NSPredicate(format: "%@ > x1 AND %@ < x0 AND %@ > y0 AND %@ < y1", argumentArray: [x, x, y, y])
        
        
        var fetchResults : [Pavillion]
        var pavillion: Pavillion?
        do {
            try fetchResults = managedObjectContext!.executeFetchRequest(fReq) as! [Pavillion]
            pavillion = fetchResults.count > 0 ? fetchResults[0] : nil
        }
        catch {
        }
        return pavillion
    }
    
    func saveEntry (title:String, pavRect:MKMapRect) {
        
        let entity = NSEntityDescription.entityForName("Pavillion", inManagedObjectContext: managedObjectContext!)
        let pavillion = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedObjectContext!)
        
        pavillion.setValue(title, forKey: "title")
        
        pavillion.setValue(pavRect.origin.x, forKey: "x0")
        pavillion.setValue(pavRect.origin.y, forKey: "y0")
        
        pavillion.setValue(pavRect.origin.x - pavRect.size.width, forKey: "x1")
        pavillion.setValue(pavRect.origin.y + pavRect.size.height, forKey: "y1")
        
        do {
            try managedObjectContext!.save()
        } catch {
            
        }
    }
}
