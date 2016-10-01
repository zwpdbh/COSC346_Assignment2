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
    var bookmarks = Array<Bookmark>()
    
    init(title: String) {
        self.title = title
    }
    
    override var description: String {
        return self.title
    }
    
    func alreadyHaveBookmark(bookmark: Bookmark) -> Bool {
        for i in 0..<self.bookmarks.count {
            if self.bookmarks[i].page == bookmark.page {
                return true
            }
        }
        return false
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
    let title: String
    let page: Int
    
    init(page: Int, title: String) {
        self.page = page
        self.title = title
    }
    
    override var hashValue: Int {
        return page
    }
}
