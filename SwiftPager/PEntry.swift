//
//  PEntry.swift
//  SwiftPager
//
//  Created by Tamas Bara on 11.12.16.
//  Copyright © 2016 Tamas Bara. All rights reserved.
//

import Foundation

class PEntry {
    var title: String!
    var text: String!
    var createdAt: Double!
    var uid: String!
    
    init(title: String, text: String, createdAt: Double, uid: String) {
        self.title = title
        self.text = text
        self.createdAt = createdAt
        self.uid = uid
    }
}
