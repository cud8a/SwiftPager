# Swift FirebasePageable

Adds paging support for large Firebase Database nodes. The paging is based on a unique double value. An example for this value is the createdAt child in each list element which should be initialized with ServerValue.TIMESTAMP.

## Usage
This will create a pageable datasource on the node 'feed' with a page size of 20 ordered by the child node 'createdAt'

    dataSource = FirebasePageableDataSource(path: "feed", pageSize: 20, orderByChild: "createdAt",
        delegate: self, getFromSnapshot: getFromSnapshot)
    
This is an example of a most basic ViewController using the PageableDataSource:

    import UIKit
    import FirebaseDatabase

    class ViewController: UIViewController, FirebasePageableDelegate, UITableViewDataSource, UITableViewDelegate {
        var dataSource: FirebasePageableDataSource!
        @IBOutlet weak var tableView: UITableView!
        
        override func viewDidLoad() {
            super.viewDidLoad()
            dataSource = FirebasePageableDataSource(path: "feed", pageSize: 15, orderByChild: "createdAt", delegate: self, getFromSnapshot: getFromSnapshot)
            
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
        }
        
        // a new item was added at the top of our list
        func itemAdded() {
            tableView.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .automatic)
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

Here is a simple model complying with the Pageable protocol by implementing the getKey function:

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

        // Pageable protocol
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
