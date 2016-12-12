//
//  PEntry.swift
//  SwiftPager
//
//  Created by Tamas Bara on 11.12.16.
//  Copyright © 2016 Tamas Bara. All rights reserved.
//

import Foundation
import FirebaseDatabase

class PEntry: Pageable {
    var title: String!
    var text: String!
    var createdAt: CLong!
    var uid: String!
    
    init(title: String, text: String, createdAt: CLong, uid: String) {
        self.title = title
        self.text = text
        self.createdAt = createdAt
        self.uid = uid
    }
    
    func getKey() -> CLong {
        return createdAt
    }
    
    init(snapshot: FIRDataSnapshot)
    {
        let entry = snapshot.value as! Dictionary<String, AnyObject>
        uid = snapshot.key
        title = entry["title"] as! String
        text = entry["text"] as! String
        createdAt = entry["createdAt"] as? CLong
    }
}
