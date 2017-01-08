//
//  ViewController.swift
//  SwiftPager
//
//  Created by Tamas Bara on 11.12.16.
//  Copyright © 2016 Tamas Bara. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ViewController: UIViewController, FirebasePageableDelegate, UITableViewDataSource, UITableViewDelegate {
    var dataSource: FirebasePageableDataSource!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = FirebasePageableDataSource(path: "feed", pageSize: 15, orderByChild: "createdAt", delegate: self, getFromSnapshot: getFromSnapshot)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PEntry")
        let entry = dataSource.pageables[indexPath.row] as! PEntry
        
        if let title = cell!.viewWithTag(1) as? UILabel {
            title.text = entry.title
        }
        
        if let text = cell!.viewWithTag(2) as? UILabel {
            text.text = entry.text
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataSource.pageables != nil {
            print("dataSource.pageables.count: \(dataSource.pageables.count)")
            return dataSource.pageables.count
        }
        
        return 0
    }
    
    // a new page was loaded, our table must be updated
    func pageLoaded() {
        tableView.reloadData()
        tableView.alpha = 1
    }
    
    // a new item was added at the top of our list
    func itemAdded() {
        tableView.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .automatic)
    }
    
    // loading in progress
    func pageLoading() {
        tableView.alpha = 0.5
    }
    
    // nothing left to load
    func lastPageLoaded() {
        tableView.alpha = 1
    }

    // convert the Firebase snapshot into our model
    func getFromSnapshot(snapshot: FIRDataSnapshot) -> Pageable {
        return PEntry(snapshot: snapshot)
    }
    
    // we scrolled to the end of our table, let´s load the next page
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) {
            dataSource.loadNextPage()
        }
    }
}
