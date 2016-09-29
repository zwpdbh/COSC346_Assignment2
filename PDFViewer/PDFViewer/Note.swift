//
//  PDFNote.swift
//  PDFViewer
//
//  Created by zwpdbh on 9/29/16.
//  Copyright © 2016 Otago. All rights reserved.
//

import Foundation

class Note: NSObject {
    var rootPDFNote: Note?
    var title: String
    var content: String
    var subNote: Array<Note>
    

    init(title: String) {
        self.rootPDFNote = nil
        self.title = title
        self.content = ""
        self.subNote = Array<Note>()
    }
    
    func numberOfChildren() -> Int {
        return self.subNote.count
    }
    
    func isItemExpandable() -> Bool {
        return subNote.count != 0 ? true: false
    }
    
    func childNoteAtIndex(index: Int) -> Note? {
        if index >= 0 && index < self.subNote.count {
            return self.subNote[index]
        } else {
            return nil
        }
    }
}