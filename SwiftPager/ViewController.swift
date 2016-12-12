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
        dataSource = FirebasePageableDataSource(path: "feed", pageSize: 20, orderByChild: "createdAt", delegate: self, getFromSnapshot: getFromSnapshot)
        
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
    
    func pageLoaded() {
        tableView.reloadData()
    }
    
    func getFromSnapshot(snapshot: FIRDataSnapshot) -> Pageable {
        return PEntry(snapshot: snapshot)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) {
            dataSource.loadNextPage()
        }
    }
}
