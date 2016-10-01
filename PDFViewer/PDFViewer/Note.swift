//
//  PDFNote.swift
//  PDFViewer
//
//  Created by zwpdbh on 9/29/16.
//  Copyright © 2016 Otago. All rights reserved.
//

import Foundation

class Note: NSObject {
    let title: String
    let page = ""
    var subnotes = Array<NoteItem>()
    var bookmarks = Set<Bookmark>()
    
    init(title: String) {
        self.title = title
    }
    
    override var description: String {
        return self.title
    }
}

class NoteItem: NSObject {
    let page: Int
    let title: String
    
    init(page: Int, title: String) {
        self.page = page
        self.title = title
    }
}

class Bookmark: NSObject {
    let page: Int
    
    init(page: Int) {
        self.page = page
    }
    
    override var hashValue: Int {
        return self.page
    }
}
