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
    
    func removeBookmarkWithPage(page: Int) -> Bool {
        for i in 0..<self.bookmarks.count {
            if page == self.bookmarks[i].page {
                self.bookmarks.removeAtIndex(i)
                return true
            }
        }
        return false
    }
    
    func removeSubnotesWithPageAndTitle(page: Int, title: String) -> Bool {
        for i in 0..<self.subnotes.count{
            let noteitem = self.subnotes[i]
            if page == noteitem.page && title == noteitem.title {
                self.subnotes.removeAtIndex(i)
                return true
            }
        }
        return false
    }
    
    func insertSubnote(item: NoteItem) {
        if item.title.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == "" {
            return
        }
        for i in 0..<self.subnotes.count {
            if self.subnotes[i].page == item.page && item.title == self.subnotes[i].title {
                return
            }
        }
        self.subnotes.append(item)
    }
    
    func updateSubnote(withitem item: NoteItem, orignalTitle title: String, orignalPage page: Int) {
        if item.title.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == "" {
            return
        }
        for i in 0..<self.subnotes.count {
            let subnote = self.subnotes[i]
            if subnote.page == page && title == subnote.title {
                subnote.title = item.title
                subnote.page = item.page
                if let content = item.content {
                    subnote.content = content
                }
            }
        }
    }
}

class NoteItem: NSObject {
    var page: Int
    var title: String
    var content: String?
    weak var parent: Note?
    
    init(page: Int, title: String, parent: Note) {
        self.page = page
        self.title = title
        self.parent = parent
    }
    
    
    override var description: String {
        if let content = self.content {
            return "title: " + title + "\npage: " + "\(page)" + "\nconent: \(content)"
        } else {
            return "title: " + title + ", page: " + "\(page)"
        }
    }
}

class Bookmark: NSObject {
    let title: String
    let page: Int
    weak var parent: Note?
    
    init(page: Int, title: String, parent: Note) {
        self.page = page
        self.title = title
        self.parent = parent
    }
    
    override var hashValue: Int {
        return page
    }
    
    override var description: String {
        return "page: " + "\(page)"
    }
}
