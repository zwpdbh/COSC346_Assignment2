//
//  PopoverViewController.swift
//  PDFViewer
//
//  Created by zwpdbh on 10/2/16.
//  Copyright © 2016 Otago. All rights reserved.
//

import Cocoa

public protocol DeteNoteItemActionDelegate {
    func deleteNoteitem(withTitle title: String, atPage page: Int)
}

class PopoverViewController: NSViewController {

    @IBOutlet weak var noteTitle: NSTextField!
    @IBOutlet var noteContent: NSTextView!
    
    
    @IBAction func deleteNoteItem(sender: NSButton) {

        let notification = NSNotification(name: "DeleteNoteItemNotification", object: nil)
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }


    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
    }

}
