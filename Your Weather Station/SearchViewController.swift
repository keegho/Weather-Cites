//
//  SearchViewController.swift
//  Your Weather Station
//
//  Created by Kegham Karsian on 2/29/16.
//  Copyright © 2016 blowmymind. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    var searchController: UISearchController!

    @IBOutlet var searchTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = true
        self.navigationItem.titleView = searchController.searchBar
        self.navigationController!.navigationBar.topItem!.title = ""
        self.definesPresentationContext = true
        let _ = self.searchController.view
        

        // Do any additional setup after loading the view.
    }
    
    deinit{
        let _ = self.searchController.view
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let Cell:UITableViewCell! =  tableView.dequeueReusableCellWithIdentifier("cell")
        
        Cell.textLabel?.text = "test"
        
        return Cell
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
