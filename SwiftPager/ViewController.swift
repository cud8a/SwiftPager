//
//  ViewController.swift
//  SwiftPager
//
//  Created by Tamas Bara on 11.12.16.
//  Copyright © 2016 Tamas Bara. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var tableData: [PEntry] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let entry = PEntry(title: "Hallo", text: "Welt", createdAt: 1469621535373, uid: "a1")
        tableData.append(entry)
        
        let ds = FirebasePageableDataSource(path: "feed", pageSize: 20, orderByChild: "createdAt")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PEntry")
        let entry = tableData[indexPath.row]
        
        if let title = cell!.viewWithTag(1) as? UILabel {
            title.text = entry.title
        }
        
        if let text = cell!.viewWithTag(2) as? UILabel {
            text.text = entry.text
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("tableData.count: \(tableData.count)")
        return tableData.count
    }
}
