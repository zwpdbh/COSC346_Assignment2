//
//  ErrorWindowController.swift
//  PDFViewer
//
//  Created by zwpdbh on 05/10/2016.
//  Copyright © 2016 Otago. All rights reserved.
//

import Cocoa

/**
 * use TableView to show the error message when load PDF has errors via loading Notes
 */
class ErrorWindowController: NSWindowController, NSTableViewDataSource {

    @IBOutlet weak var errorMessageTableView: NSTableView!
    
    var errorURLs = Array<NSURL>() {
        didSet {
            self.errorMessageTableView.reloadData()
        }
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        self.errorMessageTableView.setDataSource(self)
    }
    
    override var windowNibName: String? {
        return "ErrorWindowController"
    }
    
    func updateError(invalidURLs urls: Array<NSURL>) {
        self.errorURLs = urls
    }
 
    // MARK: - TableViewDataSource
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return self.errorURLs.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        
        if tableColumn?.title == "PDF Name" {
            return self.errorURLs[row].lastPathComponent
        } else {
            return self.errorURLs[row].absoluteString
        }
    }
}
