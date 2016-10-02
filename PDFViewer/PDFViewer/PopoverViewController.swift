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
    @IBOutlet weak var deleteButton: NSButton!
    
    @IBAction func deleteNoteItem(sender: NSButton) {
        if let item = self.noteitem {
            let info = ["noteItem": item]
            NSNotificationCenter.defaultCenter().postNotificationName("DeleteNoteItemFromPopupViewNotification", object: self, userInfo: info)
        }
    }
    
    var noteitem: NoteItem? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(receiveAndSetPopupWindowViewWithNotification), name: "AboutToEditNoteItemNotification", object: nil)
    }

    func receiveAndSetPopupWindowViewWithNotification(note: NSNotification) {
        let itemInfo = note.userInfo! as! [String: NoteItem]
        if let item = itemInfo["noteItem"]{
            self.noteitem = NoteItem(page: item.page, title: item.title, parent: item.parent!)
            self.noteitem?.content = item.content
        }
    }
}
