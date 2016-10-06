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
    @IBOutlet weak var errorInfor: NSTextField!
    
    @IBAction func deleteNoteItem(sender: NSButton) {
        // if during the adding process, user click the delete button, then cancel the process, close pop up window
        if isAdding {
            NSNotificationCenter.defaultCenter().postNotificationName("DeleteNoteItemFromPopupViewNotification", object: nil)
        }
        // if the during the process of editing, when user click the delete button, delete the editing noteItem. 
        if let item = self.noteitem {
            let info = ["noteItem": item]
            NSNotificationCenter.defaultCenter().postNotificationName("DeleteNoteItemFromPopupViewNotification", object: self, userInfo: info)
        }
    }
    
    var noteitem: NoteItem? = nil
    var isAdding: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(receiveAndSetPopupWindowViewWithNotification), name: "AboutToEditNoteItemNotification", object: nil)
    }

    // use notification to configure pop up window. Such as populate title and content if the user is chaning the note
    func receiveAndSetPopupWindowViewWithNotification(note: NSNotification) {
        let itemInfo = note.userInfo! as! [String: NoteItem]
        if let item = itemInfo["noteItem"]{
            isAdding = false
            self.noteitem = NoteItem(page: item.page, title: item.title, parent: item.parent!)
            self.noteitem?.content = item.content
        }
    }
}
