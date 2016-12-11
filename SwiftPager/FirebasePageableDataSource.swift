//
//  FirebasePageableDataSource.swift
//  SwiftPager
//
//  Created by Tamas Bara on 11.12.16.
//  Copyright © 2016 Tamas Bara. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol Pageable {
    func getKey() -> Double
}

class FirebasePageableDataSource {
    var pageables: [Pageable]!
    var getFromSnapshot: ((FIRDataSnapshot)->Pageable)!
    
    var path: String!
    var pageSize: Int!
    var orderByChild: String!
    
    init(path: String, pageSize: Int, orderByChild: String) {
        self.path = path
        self.pageSize = pageSize
        self.orderByChild = orderByChild
        
        let query = FIRDatabase.database().referenceWithPath(path).queryOrderedByChild(orderByChild).queryLimitedToLast(20)
        query.observeSingleEventOfType(.Value, withBlock:
        { (snapshot) in
            print("snapshot: \(snapshot)")
        })
    }
}
