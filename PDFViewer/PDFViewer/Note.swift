//
//  PDFNote.swift
//  PDFViewer
//
//  Created by zwpdbh on 9/29/16.
//  Copyright © 2016 Otago. All rights reserved.
//

import Foundation
import Quartz

class Note: NSObject, NSCoding {
    var pdfURL: NSURL
    var subnotes = Array<NoteItem>()
    var bookmarks = Array<Bookmark>()
    var resultGroup = Array<SearchResult>()
    var title: String {
        return self.pdfURL.lastPathComponent!
    }
    
    var col1: String {
        return title
    }
    var col2: String {
        return ""
    }
    
    init(url: NSURL) {
        self.pdfURL = url
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.pdfURL, forKey: "zwpdbh.Note.pdfURL")
        aCoder.encodeObject(self.subnotes, forKey: "zwpdbh.Note.subnotes")
        aCoder.encodeObject(self.bookmarks, forKey: "zwpdbh.Note.bookmarks")
        aCoder.encodeObject(self.resultGroup, forKey: "zwpdbh.Note.resultsGroup")
    }
    
    required init(coder aDecoder: NSCoder) {
        self.pdfURL = aDecoder.decodeObjectForKey("zwpdbh.Note.pdfURL") as! NSURL
        self.subnotes = aDecoder.decodeObjectForKey("zwpdbh.Note.subnotes") as! Array<NoteItem>
        self.bookmarks = aDecoder.decodeObjectForKey("zwpdbh.Note.bookmarks") as! Array<Bookmark>
        self.resultGroup = aDecoder.decodeObjectForKey("zwpdbh.Note.resultsGroup") as! Array<SearchResult>
        super.init()
    }
    
    override var description: String {
        return self.title
    }
    
    func addResultSelections(instance: PDFSelection, parent: Note) {
        if let item = instance.pages().first as? PDFPage {
            print(item)
            instance.setColor(NSColor.yellowColor())
            for each in self.resultGroup {
                if Int(item.label()) == each.page {
                    each.addSelections(instance)
                    return
                }
            }
            let searchResult = SearchResult(page: Int(item.label())!, parent: parent)
            searchResult.addSelections(instance)
            self.resultGroup.append(searchResult)
        }
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

class NoteItem: NSObject, NSCoding {
    var page: Int
    var title: String
    var content: String?
    weak var parent: Note?
    
    var col1: String {
        return title
    }
    var col2: String {
        return "\(page)"
    }
    
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
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.page, forKey: "zwpdbh.NoteItem.page")
        aCoder.encodeObject(self.title, forKey: "zwpdbh.NoteItem.title")
        aCoder.encodeObject(self.content, forKey: "zwpdbh.NoteItem.content")
        aCoder.encodeConditionalObject(self.parent, forKey: "zwpdbh.NoteItem.parent")
    }
    
    required init(coder aDecoder: NSCoder) {
        self.page = aDecoder.decodeObjectForKey("zwpdbh.NoteItem.page") as! Int
        self.title = aDecoder.decodeObjectForKey("zwpdbh.NoteItem.title") as! String
        self.content = aDecoder.decodeObjectForKey("zwpdbh.NoteItem.content") as? String
        self.parent = aDecoder.decodeObjectForKey("zwpdbh.NoteItem.parent") as? Note
        super.init()
    }
}

class Bookmark: NSObject, NSCoding {
    var title: String
    var page: Int
    weak var parent: Note?
    
    var col1: String {
        return title
    }
    var col2: String {
        return "\(page)"
    }
    
    init(page: Int, title: String, parent: Note) {
        self.page = page
        self.title = title
        self.parent = parent
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.title, forKey: "zwpdbh.Bookmark.title")
        aCoder.encodeObject(self.page, forKey: "zwpdbh.Bookmark.page")
        aCoder.encodeConditionalObject(self.parent, forKey: "zwpdbh.Bookmark.parent")
    }
    
    
    
    required init(coder aDecoder: NSCoder) {
        self.title = aDecoder.decodeObjectForKey("zwpdbh.Bookmark.title") as! String
        self.page = aDecoder.decodeObjectForKey("zwpdbh.Bookmark.page") as! Int
        self.parent = aDecoder.decodeObjectForKey("zwpdbh.Bookmark.parent") as? Note
        super.init()
    }
    
    override var hashValue: Int {
        return page
    }
    
    override var description: String {
        return "page: " + "\(page)"
    }
}

class SearchResult: NSObject, NSCoding {
    let page: Int
    var results = Array<PDFSelection>()
    
    weak var parent: Note?
    var times: Int {
        return results.count
    }
    
    var col1: String {
        return "\(page)"
    }
    var col2: String {
        return "\(times)"
    }
    
    init(page: Int, parent: Note) {
        self.page = page
        self.parent = parent
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.page, forKey: "zwpdbh.SearchResult.page")
        aCoder.encodeObject(self.results, forKey: "zwpdbh.SearchResult.results")
        aCoder.encodeConditionalObject(self.parent, forKey: "zwpdbh.SearchResult.parent")
    }

    required init?(coder aDecoder: NSCoder) {
        self.page = aDecoder.decodeObjectForKey("zwpdbh.SearchResult.page") as! Int
        self.results = aDecoder.decodeObjectForKey("zwpdbh.SearchResult.results") as! Array<PDFSelection>
        self.parent = aDecoder.decodeObjectForKey("zwpdbh.SearchResult.parent") as? Note
        
    }
    
    func addSelections(selection: PDFSelection) {
        if self.results.count > 1 {
            self.results[0].addSelection(selection)
        }
        self.results.append(selection)
    }
}

