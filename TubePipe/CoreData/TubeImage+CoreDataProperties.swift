//
//  TubeImage+CoreDataProperties.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-07.
//
//

import Foundation
import CoreData


extension TubeImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TubeImage> {
        return NSFetchRequest<TubeImage>(entityName: "TubeImage")
    }

    @NSManaged public var data: Data?
    @NSManaged public var id: String?
    @NSManaged public var tube: TubeModel?

}

extension TubeImage : Identifiable {

}
