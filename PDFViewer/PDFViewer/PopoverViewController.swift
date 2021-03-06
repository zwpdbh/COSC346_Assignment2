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
    
    @IBAction func deleteNoteItem(_ sender: NSButton) {
        // if during the adding process, user click the delete button, then cancel the process, close pop up window
        if isAdding {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "DeleteNoteItemFromPopupViewNotification"), object: nil)
        }
        // if the during the process of editing, when user click the delete button, delete the editing noteItem. 
        if let item = self.noteitem {
            let info = ["noteItem": item]
            NotificationCenter.default.post(name: Notification.Name(rawValue: "DeleteNoteItemFromPopupViewNotification"), object: self, userInfo: info)
        }
    }
    
    var noteitem: NoteItem? = nil
    var isAdding: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        NotificationCenter.default.addObserver(self, selector: #selector(receiveAndSetPopupWindowViewWithNotification), name: NSNotification.Name(rawValue: "AboutToEditNoteItemNotification"), object: nil)
    }

    // use notification to configure pop up window. Such as populate title and content if the user is chaning the note
    func receiveAndSetPopupWindowViewWithNotification(_ note: Notification) {
        let itemInfo = (note as NSNotification).userInfo! as! [String: NoteItem]
        if let item = itemInfo["noteItem"]{
            isAdding = false
            self.noteitem = NoteItem(page: item.page, title: item.title, parent: item.parent!)
            self.noteitem?.content = item.content
        }
    }
}
