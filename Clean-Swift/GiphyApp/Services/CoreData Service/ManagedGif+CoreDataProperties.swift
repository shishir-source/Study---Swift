//
//  ManagedGif+CoreDataProperties.swift
//  GiphyApp
//
//  Created by Shishir Ahmed on 1/6/24.
//
//

import Foundation
import CoreData


extension ManagedGif {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedGif> {
        return NSFetchRequest<ManagedGif>(entityName: "ManagedGif")
    }

    @NSManaged public var gifImage: NSData?

}
