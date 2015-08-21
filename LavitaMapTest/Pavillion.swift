//
//  Pavillion.swift
//  CoreTest
//
//  Created by Admin on 20/08/15.
//  Copyright © 2015 Lavita. All rights reserved.
//
import Foundation
import CoreData

@objc(Pavillion)
class Pavillion: NSManagedObject {
    
    @NSManaged var title: String
    @NSManaged var x0: Double
    @NSManaged var y0: Double
    @NSManaged var x1: Double
    @NSManaged var y1: Double
}