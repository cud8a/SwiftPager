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
    func getKey() -> CLong
}

protocol FirebasePageableDelegate {
    func pageLoading()
    func pageLoaded()
    func lastPageLoaded()
    func itemAdded()
}

class FirebasePageableDataSource {
    var pageables: [Pageable]!
    var getFromSnapshot: ((FIRDataSnapshot)->Pageable)!
    
    var path: String!
    var pageSize: UInt!
    var orderByChild: String!
    
    var delegate: FirebasePageableDelegate!
    var valueWhereTheNextPageBegins: CLong?
    
    var loadingNextPage = false
    var nothingLeftToLoad = false
    
    var ignoreFirstAdd = true
    
    init(path: String, pageSize: UInt, orderByChild: String, delegate: FirebasePageableDelegate, getFromSnapshot: @escaping ((FIRDataSnapshot)->Pageable)) {
        self.path = path
        self.pageSize = pageSize
        self.orderByChild = orderByChild
        self.delegate = delegate
        self.getFromSnapshot = getFromSnapshot
        pageables = []
        
        let query = FIRDatabase.database().reference(withPath: path).queryOrdered(byChild: orderByChild).queryLimited(toLast: pageSize)
        query.observeSingleEvent(of: .value, with: {
        (snapshot) in
            self.addPage(snapshot: snapshot, atIndex: 0, ignoreLastEntry: false)
            
            let queryForListeningToAdds = FIRDatabase.database().reference(withPath: path).queryOrdered(byChild: orderByChild).queryLimited(toLast: 1)
            queryForListeningToAdds.observe(FIRDataEventType.childAdded, with: {
                (snapshot) in
                if !self.ignoreFirstAdd && !self.loadingNextPage {
                    let entry = self.getFromSnapshot(snapshot)
                    self.pageables.insert(entry, at: 0)
                    self.delegate.itemAdded()
                }
                
                self.ignoreFirstAdd = false
            })
        })
    }
    
    private func addPage(snapshot: FIRDataSnapshot, atIndex: Int, ignoreLastEntry: Bool) {
        var firstEntry: Pageable?
        var added: UInt = 0
        var maxAdd = snapshot.childrenCount
        if ignoreLastEntry {
            maxAdd = maxAdd - 1
        }
        
        for child in snapshot.children {
            if added < maxAdd {
                if let snap = child as? FIRDataSnapshot {
                    let entry = self.getFromSnapshot(snap)
                
                    if firstEntry == nil {
                        firstEntry = entry
                    }
                    
                    self.pageables.insert(entry, at: atIndex)
                    added = added + 1
                }
            }
        }
        
        if firstEntry != nil {
            self.valueWhereTheNextPageBegins = firstEntry!.getKey()
            delegate.pageLoaded()
        } else {
            nothingLeftToLoad = true
            delegate.lastPageLoaded()
        }
    }
    
    func loadNextPage() {
        if nothingLeftToLoad {
            print("FirebasePageableDataSource: nothing left to load")
        } else {
            if !loadingNextPage {
                delegate.pageLoading()
                loadingNextPage = true
                print("FirebasePageableDataSource: loading next page")
                let query = FIRDatabase.database().reference(withPath: path).queryOrdered(byChild: orderByChild).queryEnding(atValue: valueWhereTheNextPageBegins).queryLimited(toLast: pageSize)
                query.observeSingleEvent(of: .value, with: {
                    (snapshot) in
                    self.addPage(snapshot: snapshot, atIndex: self.pageables.count, ignoreLastEntry: true)
                    self.loadingNextPage = false
                })
            }
        }
    }
}
