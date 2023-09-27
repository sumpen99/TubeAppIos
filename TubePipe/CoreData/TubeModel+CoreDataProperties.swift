//
//  TubeModel+CoreDataProperties.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-08-07.
//
//

import Foundation
import CoreData


extension TubeModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TubeModel> {
        return NSFetchRequest<TubeModel>(entityName: "TubeModel")
    }

    @NSManaged public var center: Float
    @NSManaged public var date: Date?
    @NSManaged public var dimension: Float
    @NSManaged public var grader: Float
    @NSManaged public var id: String?
    @NSManaged public var lena: Float
    @NSManaged public var lenb: Float
    @NSManaged public var message: String?
    @NSManaged public var radie: Float
    @NSManaged public var segment: Float
    @NSManaged public var steel: Float
    @NSManaged public var image: TubeImage?

}

extension TubeModel : Identifiable {

}
