//
//  PDFNote.swift
//  PDFViewer
//
//  Created by zwpdbh on 9/29/16.
//  Copyright © 2016 Otago. All rights reserved.
//

import Foundation
import Quartz


/**
 * My notes model. Each opened PDF file will associated with one note.
 * Each note contains:
 * pdfURL: indicate where the PDF has been loaded
 * subnotes: is an array of NoteItem. Once user use popover view to write down a note, it is saved as NoteItem.
 * bookmask: is an array of Bookmark. Once user use button to add one bookmark, it is saved as a Bookmark
 * resultGroup: is an array of SearchResult. Each SearchResult represent all matched String on one PDFPage.
 * col1, col2 is used as outlineView key-value binding.
 */
class Note: NSObject, NSCoding {
    var pdfURL: URL
    var subnotes = Array<NoteItem>()
    var bookmarks = Array<Bookmark>()
    var resultGroup = Array<SearchResult>()
    var title: String {
        return self.pdfURL.lastPathComponent
    }
    
    var col1: String {
        return title
    }
    var col2: String {
        return ""
    }
    
    init(url: URL) {
        self.pdfURL = url
    }
    
    // used for Archive, for saving data
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.pdfURL, forKey: "zwpdbh.Note.pdfURL")
        aCoder.encode(self.subnotes, forKey: "zwpdbh.Note.subnotes")
        aCoder.encode(self.bookmarks, forKey: "zwpdbh.Note.bookmarks")
        aCoder.encode(self.resultGroup, forKey: "zwpdbh.Note.resultsGroup")
    }
    
    // used for UNArchive, for loading data
    required init(coder aDecoder: NSCoder) {
        self.pdfURL = aDecoder.decodeObject(forKey: "zwpdbh.Note.pdfURL") as! URL
        self.subnotes = aDecoder.decodeObject(forKey: "zwpdbh.Note.subnotes") as! Array<NoteItem>
        self.bookmarks = aDecoder.decodeObject(forKey: "zwpdbh.Note.bookmarks") as! Array<Bookmark>
        self.resultGroup = aDecoder.decodeObject(forKey: "zwpdbh.Note.resultsGroup") as! Array<SearchResult>
        super.init()
    }
    
    override var description: String {
        return self.title
    }
    
    /**
     * Add one PDFSelection into one Note, meanwhile also record in which Note this PDFSelection belongs
     * Because, the search is doing among multiple PDFs, so when it adds a result, it needs to distinguish
     * which Note(associated with PDF) it belongs to.
     */
    func addResultSelections(_ instance: PDFSelection, parent: Note) {
        if let item = instance.pages.first as? PDFPage {
            instance.color = NSColor.yellow
            for eachSearchResult in self.resultGroup {
                if Int(item.label) == eachSearchResult.page {
                    eachSearchResult.addSelectionsIntoGroup(instance)
                    return
                }
            }
            let searchResult = SearchResult(page: Int(item.label)!, parent: parent)
            searchResult.addSelectionsIntoGroup(instance)
            self.resultGroup.append(searchResult)
        }
    }
    
    // one page for one bookmark. Check if there is already a bookmark at that page.
    func alreadyHaveBookmark(_ bookmark: Bookmark) -> Bool {
        for i in 0..<self.bookmarks.count {
            if self.bookmarks[i].page == bookmark.page {
                return true
            }
        }
        return false
    }
    
    // when user use Backspace to delete bookmark, remove the bookmark on that page.
    func removeBookmarkWithPage(_ page: Int) -> Bool {
        for i in 0..<self.bookmarks.count {
            if page == self.bookmarks[i].page {
                self.bookmarks.remove(at: i)
                return true
            }
        }
        return false
    }
    
    // remove one note with specified title and page.
    func removeSubnotesWithPageAndTitle(_ page: Int, title: String) -> Bool {
        for i in 0..<self.subnotes.count{
            let noteitem = self.subnotes[i]
            if page == noteitem.page && title == noteitem.title {
                self.subnotes.remove(at: i)
                return true
            }
        }
        return false
    }
    
    // insert a note
    func insertSubnote(_ item: NoteItem) {
        if isValidated(item, isAdding: true, exceptTitle: nil) {
            self.subnotes.append(item)
        }
    }
    
    // Update a noteItem, based on orignal note's title and page
    func updateSubnote(withitem item: NoteItem, orignalTitle title: String, orignalPage page: Int) {
        if isValidated(item, isAdding: false, exceptTitle: title) {
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
    
    /**
     * check if the submited title is whether valid or note. Title can not be empty and it should be unique on one page.
     * @NoteItem is the submited NoteItem
     * @isAdding indicate this submition is an updating or insertion
     * @exceptTitle is the title you want to exclude when it is an updating: you are updating the primary key
     */
    func isValidated(_ item: NoteItem, isAdding: Bool, exceptTitle: String?) -> Bool {
        
        if item.title.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "" {
            return false
        } else if isRedundantTitleWithinPage(item, isAdding: isAdding, exceptTitle: nil) {
            return false
        }
        return true
    }
    
    /**
     * check if the submited title is whether repeated or unique.
     * @NoteItem is the submited NoteItem
     * @isAdding indicate this submition is an updating or insertion
     * @exceptTitle is the title you want to exclude when it is an updating: you are updating the primary key
     */
    fileprivate func isRedundantTitleWithinPage(_ item: NoteItem, isAdding: Bool, exceptTitle: String?) -> Bool {
        if isAdding {
            for each in self.subnotes {
                if each.page == item.page && each.title == item.title {
                    return true;
                }
            }
        } else if exceptTitle != nil {
            for each in self.subnotes {
                if each.page == item.page && each.title == item.title && item.title != exceptTitle! {
                    return true
                }
            }
        }

        return false
    }
}

/**
 * One NoteItem contains:
 * page: the page number
 * title: the title of the note
 * content: the content of the note
 * parent: which Note this NoteItem belongs to 
 * col1, col2 are for outlineView key-value binding
 */
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
    
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.page, forKey: "zwpdbh.NoteItem.page")
        aCoder.encode(self.title, forKey: "zwpdbh.NoteItem.title")
        aCoder.encode(self.content, forKey: "zwpdbh.NoteItem.content")
        aCoder.encodeConditionalObject(self.parent, forKey: "zwpdbh.NoteItem.parent")
    }
    
    required init(coder aDecoder: NSCoder) {
        self.page = aDecoder.decodeObject(forKey: "zwpdbh.NoteItem.page") as! Int
        self.title = aDecoder.decodeObject(forKey: "zwpdbh.NoteItem.title") as! String
        self.content = aDecoder.decodeObject(forKey: "zwpdbh.NoteItem.content") as? String
        self.parent = aDecoder.decodeObject(forKey: "zwpdbh.NoteItem.parent") as? Note
        super.init()
    }
}

/**
 * A Bookmark represents a bookmark user added on one page, it contains:
 * title: the title of the bookmark
 * page: the page number in the PDF
 * parent: which note this Bookmark belongs to
 * col1, col2 are for outlineView key-value binding
 * A Bookmark is unique on one page.
 */
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
    
    // encode method for conforming NSCoding protocol
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.title, forKey: "zwpdbh.Bookmark.title")
        aCoder.encode(self.page, forKey: "zwpdbh.Bookmark.page")
        aCoder.encodeConditionalObject(self.parent, forKey: "zwpdbh.Bookmark.parent")
    }
    
    // decode method for conforming NSCoding protocal
    required init(coder aDecoder: NSCoder) {
        self.title = aDecoder.decodeObject(forKey: "zwpdbh.Bookmark.title") as! String
        self.page = aDecoder.decodeObject(forKey: "zwpdbh.Bookmark.page") as! Int
        self.parent = aDecoder.decodeObject(forKey: "zwpdbh.Bookmark.parent") as? Note
        super.init()
    }
    
    override var hashValue: Int {
        return page
    }
    
    override var description: String {
        return "page: " + "\(page)"
    }
}

/**
 * A SearchResult represent the search result on one page, contains:
 * page: page number of the PDF
 * results: it is an array of PDFSelection which highlights all the matched parts
 * parent: Because the search is search though multiple PDFs, so the SearchResult also
 *         need to record which Note(associated with PDF) this SearchResult belongs to.
 * times: records the occuring times the searching String appears on one page
 * col1, col2 are for outlineView key-value binding
 */
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
    
    // encode method for comforming the NSCoding protocol
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.page, forKey: "zwpdbh.SearchResult.page")
        aCoder.encode(self.results, forKey: "zwpdbh.SearchResult.results")
        aCoder.encodeConditionalObject(self.parent, forKey: "zwpdbh.SearchResult.parent")
    }
    
    // decode method for comforming the NSCoding protocol
    required init?(coder aDecoder: NSCoder) {
        self.page = aDecoder.decodeObject(forKey: "zwpdbh.SearchResult.page") as! Int
        self.results = aDecoder.decodeObject(forKey: "zwpdbh.SearchResult.results") as! Array<PDFSelection>
        self.parent = aDecoder.decodeObject(forKey: "zwpdbh.SearchResult.parent") as? Note
        
    }
    
    /**
     * add one PDFSelection into results array, meanwhile making the first PDFSelection include
     * all the PDFSelection on the same page, so during high lighting, 
     * it shows all the matching part on one page.
     */
    func addSelectionsIntoGroup(_ selection: PDFSelection) {
        if self.results.count > 0 {
            self.results[0].add(selection)
        }
        self.results.append(selection)
    }
}

