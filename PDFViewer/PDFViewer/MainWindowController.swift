//
//  MainWindowController.swift
//  PDFViewer
//
//  Created by zwpdbh on 9/28/16.
//  Copyright © 2016 Otago. All rights reserved.
//

import Cocoa
import Quartz


class MainWindowController: NSWindowController, PDFViewerDelegate, NSOutlineViewDataSource, NSOutlineViewDelegate, NSPopoverDelegate {

    // MARK: - Outlets and Actions
    @IBOutlet weak var currentPageDisplay: NSTextField!
    
    @IBOutlet weak var pdfView: PDFView!
    
    @IBOutlet weak var addNoteButton: NSButton!
    
    @IBOutlet weak var outlineView: NSOutlineView!
    
    @IBOutlet weak var outlineOption: NSPopUpButton!
    
    @IBOutlet weak var searchTextField: NSTextField!
    
    @IBAction func outlineOptionSelect(sender: NSPopUpButtonCell) {
        self.selectedOutLineOption = self.outlineOption.indexOfSelectedItem
        if self.selectedOutLineOption == 0 {
            self.outlineView.tableColumns[0].title = "time"
            self.outlineView.tableColumns[1].title = "at page"
        } else if self.selectedOutLineOption == 1{
            self.outlineView.tableColumns[0].title = "note title"
            self.outlineView.tableColumns[1].title = "at page"
        } else if self.selectedOutLineOption == 2 {
            self.outlineView.tableColumns[0].title = "at page"
            self.outlineView.tableColumns[1].title = "times"
        }
        self.outlineView.reloadData()
    }
    
    @IBAction func addBookmark(sender: NSButton) {
        if let set = self.pdfSet {
            let page = set.getCurrentPage()
            let title = "page: \(page)"
            
            let note = self.notes[self.indexOfSelectedPDF]
            let bookmark = Bookmark(page: page, title: title, parent: note)
            
            if !note.alreadyHaveBookmark(bookmark) {
                
                note.bookmarks.append(bookmark)
                
                self.outlineView.reloadData()
            }
        }
    }
    
    @IBAction func addNote(sender: NSButton) {
        if let _ = self.pdfSet {
            // show popover when click addnote button
            isAdding = true
            popover.showRelativeToRect(self.addNoteButton.bounds, ofView: self.addNoteButton, preferredEdge: NSRectEdge.MinY)
        }
    }
    @IBAction func saveNotes(sender: NSMenuItem) {
        // should save all notes under the same direcotry with pdfs
        for eachNote in self.notes {
            if let savingURL = getNoteURLFromPDFURL(eachNote.pdfURL).path {
                let result = NSKeyedArchiver.archiveRootObject(eachNote, toFile: savingURL)
                if result {
                    print("save note succeed, at: " + savingURL)
                } else {
                    print("save note failed, when try to save note at: " + savingURL)
                }
            }
        }
    }
    
    // save ntoes
    func getNoteURLFromPDFURL(url: NSURL) -> NSURL {
        var savingURL = ""
        if let parts = url.pathComponents {
            for  i in 1..<parts.count-1 {
                if i == 1 {
                    savingURL += parts[i]
                } else {
                    savingURL += ("/" + parts[i])
                }
            }
            savingURL = "/" + savingURL + "/" + parts[parts.count-1] + ".note"
        }
        
        return NSURL(fileURLWithPath: savingURL)
    }
    
    // open notes
    @IBAction func openNotes(sender: NSMenuItem) {
        // open notes and load associated files
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true;
        
        panel.beginWithCompletionHandler { (result) in
            if result == NSFileHandlingPanelOKButton {
                self.pdfSet = nil
                var pdfURLs: Array<NSURL> = []
                self.notes = []
                for url in panel.URLs {
                    if let note = NSKeyedUnarchiver.unarchiveObjectWithFile(url.path!) as? Note {
                        self.notes.append(note)
                        pdfURLs.append(note.pdfURL)
                    }
                }
                self.pdfSet = PDFSet(pdfURLS: pdfURLs)
                
                if let set = self.pdfSet {
                    for url in set.addresses {
                        self.selectPDFButton.addItemWithTitle(url.lastPathComponent!)
                    }
                    set.setPDFDocumentsDelegate(self)
                    set.delegate = self
                    self.pdfView.setDocument(set.moveToGivenPDF(0))
                }
                self.outlineView.reloadData()
            }
        }
    }
    
    @IBOutlet weak var selectPDFButton: NSPopUpButton!
    
    // MARK: - Action
    // open pdf files and put them into array
    @IBAction func openFile(sender: NSMenuItem) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true;
        
        panel.beginWithCompletionHandler { (result) in
            if(result == NSFileHandlingPanelOKButton) {
                self.selectPDFButton.removeAllItems()
                self.pdfSet = PDFSet(pdfURLS: panel.URLs)
                
                // one pdf file for one note, reset notes
                self.notes = Array<Note>()
                
                if let set = self.pdfSet {
                    for url in set.addresses {
                        self.selectPDFButton.addItemWithTitle(url.lastPathComponent!)
                        if let note = self.getNoteFromURL(url) {
                            self.notes.append(note)
                        } else {
                            self.notes.append(Note(url: url))
                        }
                    }
                    
                    set.setPDFDocumentsDelegate(self)
                    set.delegate = self
                    self.pdfView.setDocument(set.moveToGivenPDF(0))
                }
                self.outlineView.reloadData()
            }
        }
    }
    
    func getNoteFromURL(pdfURL: NSURL) -> Note? {
        let noteURL = getNoteURLFromPDFURL(pdfURL)
        var error: NSError?
        let noteExist = noteURL.checkResourceIsReachableAndReturnError(&error)
        if noteExist {
            return NSKeyedUnarchiver.unarchiveObjectWithFile(noteURL.path!) as? Note
        } else {
            return nil
        }
    }
    
    // go to previous page
    @IBAction func previousPage(sender: NSButton) {
        if let set = self.pdfSet {
            if let page = set.moveToPreviousPage() {
                self.pdfView.goToPage(page)
            }
        }
    }
    
    
    // go to the next page
    @IBAction func nextPage(sender: NSButton) {
        if let set = self.pdfSet {
            if let page = set.moveToNextPage() {
                self.pdfView.goToPage(page)
            }
        }
    }
    
    // go to the Given page
    @IBAction func goToGivenPage(sender: NSTextField) {
        if let set = self.pdfSet {
            if let pageNumber = Int(sender.stringValue) {
                if let page = set.moveToGivenPage(pageNumber) {
                    self.pdfView.goToPage(page)
                }
            }
        }
    }
    
    // if there is not one pdf, then click this can go to previous one
    @IBAction func goToPreviousPDF(sender: NSButton) {
        if let set = self.pdfSet {
            if let pdf = set.moveToPreviousPDF() {
                self.pdfView.setDocument(pdf)
            }
        }

    }
    
    // if there is not one pdf, then click this can to to next one
    @IBAction func goToNextPDF(sender: NSButton) {
        if let set = self.pdfSet {
            if let pdf = set.moveToNextPDF() {
                self.pdfView.setDocument(pdf)
            }
        }
    }
    
    // move to selected pdf
    @IBAction func selectPDF(sender: NSPopUpButtonCell) {
        if let set = self.pdfSet {
            let selectedIndex = self.selectPDFButton.indexOfSelectedItem
            if let pdf = set.moveToGivenPDF(selectedIndex) {
                self.pdfView.setDocument(pdf)
            }
        }
        
    }
    
    @IBAction func zoomIn(sender: NSButton) {
        self.pdfView.zoomIn(sender)
    }
    
    @IBAction func zoomOut(sender: NSButton) {
        self.pdfView.zoomOut(sender)
    }
    
    @IBAction func resetZoom(sender: NSButton) {
        self.pdfView.setAutoScales(true)
    }
    
    // MARK: - Model Variables
    // a array of pdfs
    var pdfSet: PDFSet?
    var notes: Array<Note> = []
    // use this index to put search result into separete note
    var indexOfNote: Int = 0
    
    var indexOfSelectedPDF = 1
    // 0 means viewing bookmarks, 1 means viewing notes
    var selectedOutLineOption = 0
    
    let popover = NSPopover()
    
    var popoverViewController : PopoverViewController?
    
    var isAdding: Bool =  false
    var editingNoteItem: NoteItem?
    
    // MARK: - Action Related to Window
    func windowDidResize(notification: NSNotification) {
        self.pdfView.setAutoScales(true)
    }

    override var windowNibName: String? {
        return "MainWindowController"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        // Notification for scroll of pages
        NSNotificationCenter.defaultCenter().postNotificationName(PDFViewPageChangedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(pageChangedAfterScroll), name: PDFViewPageChangedNotification, object: nil)
        
        // Notification for delete action on popup view
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(deleteNoteItemWithNotification), name: "DeleteNoteItemFromPopupViewNotification", object: nil)
        
        // set up popover controller
        self.popoverViewController = PopoverViewController(nibName: "PopoverViewController", bundle: nil)!
        self.popover.contentViewController = self.popoverViewController
        self.popover.behavior = NSPopoverBehavior.Transient
        self.popover.delegate = self
        
        // setup notifications for search
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didBeginFind), name: PDFDocumentDidBeginFindNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didEndFind), name: PDFDocumentDidEndFindNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didFindMatch), name: PDFDocumentDidFindMatchNotification, object: nil)
        
    }
    
    // Recieve notification: update view, set current pdf to certain page, and update current page info
    func pageChangedAfterScroll() {
        if let page = self.pdfView.currentPage() {
            self.pdfSet!.setPage(page)
        }
    }
    
    // MARK: - PDFSetDelegate A self defined protocol to sync info
    func pdfInfoNeedChangeTo(nthPDF: Int, totalPDFs: Int, title: String, page: Int, totalPages: Int) {
        self.window?.title = "\(nthPDF)/\(totalPDFs)_" + title
        self.currentPageDisplay.stringValue = "\(page)/\(totalPages)"
        self.indexOfSelectedPDF = nthPDF - 1
        self.selectPDFButton.selectItemAtIndex(nthPDF - 1)
    }
    
    

    // MARK: - NSOutlineViewDataSource
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        
        if let note = item as? Note{
            if selectedOutLineOption == 1 {
                return note.subnotes.count
            } else if selectedOutLineOption == 0 {
                return note.bookmarks.count
            } else if selectedOutLineOption == 2 {
                return note.resultGroup.count
            }
        }
        return self.notes.count
    }
    
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        if let note = item as? Note {
            if selectedOutLineOption == 1 {
                return note.subnotes[index]
            } else if selectedOutLineOption == 0 {
                return note.bookmarks[index]
            } else if selectedOutLineOption == 2 {
                return note.resultGroup[index]
            }
        }
        
        return self.notes[index]
    }
    
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        if let note = item as? Note {
            if selectedOutLineOption == 1 {
                return note.subnotes.count > 0
            } else if selectedOutLineOption == 0 {
                return note.bookmarks.count > 0
            } else if selectedOutLineOption == 2 {
                return note.resultGroup.count > 0
            }
        }
        return false
    }
    
    func outlineView(outlineView: NSOutlineView, objectValueForTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) -> AnyObject? {
        if let note = item as? Note {
            return note
        } else if let noteItem = item as? NoteItem {
            return noteItem
        } else if let bookmark = item as? Bookmark {
            return bookmark
        } else if let result = item as? SearchResult {
            return result
        }
        return nil
    }
    
    
    // MARK: - NSOutlineViewDelegate
    
    func outlineViewSelectionDidChange(notification: NSNotification) {
        let row = self.outlineView.selectedRow
        if let item = self.outlineView.itemAtRow(row) {
            if let bookmark = item as? Bookmark {
                if let parent = bookmark.parent {
                    let pdfIndex = self.pdfSet?.getIndexByTitle(parent.title)
                    // simulate select popup button
                    self.selectPDFButton.selectItemAtIndex(Int(pdfIndex!))
                    self.selectPDF(self.selectPDFButton.selectedCell() as! NSPopUpButtonCell)
                    // simulate go to a given page
                    self.currentPageDisplay.stringValue = "\(bookmark.page)"
                    self.goToGivenPage(self.currentPageDisplay)
                }
            } else if let noteItem = item as? NoteItem {
                isAdding = false
                // prepare to go to certian page within certain PDF
                if let parent = noteItem.parent {
                    let pdfIndex = self.pdfSet?.getIndexByTitle(parent.title)
                    // simulate select popup button
                    self.selectPDFButton.selectItemAtIndex(Int(pdfIndex!))
                    self.selectPDF(self.selectPDFButton.selectedCell() as! NSPopUpButtonCell)
                    // simulate go to a given page
                    self.currentPageDisplay.stringValue = "\(noteItem.page)"
                    self.goToGivenPage(self.currentPageDisplay)
                    
                    // record the noteitem which will be changed
                    editingNoteItem = noteItem
                    popover.showRelativeToRect(self.outlineView.frameOfOutlineCellAtRow(row), ofView: self.outlineView.viewAtColumn(0, row: row, makeIfNecessary: false)!, preferredEdge: NSRectEdge.MinY)
                    
                    let noteItemInfo = ["noteItem": noteItem]
                    NSNotificationCenter.defaultCenter().postNotificationName("AboutToEditNoteItemNotification", object: self, userInfo: noteItemInfo as [NSObject : AnyObject])
                }
            } else if let searchResult = item as? SearchResult {
                if let parent = searchResult.parent {
                    let pdfIndex = self.pdfSet?.getIndexByTitle(parent.title)
                    // simulate select popup button
                    self.selectPDFButton.selectItemAtIndex(Int(pdfIndex!))
                    self.selectPDF(self.selectPDFButton.selectedCell() as! NSPopUpButtonCell)
                }
                if let selection = searchResult.results.first {
                    self.pdfView.setCurrentSelection(selection)
                    self.pdfView.scrollSelectionToVisible(self)
                }
            }
        }
    }
    
    
    // MARK: - key event
    override func keyDown(theEvent: NSEvent) {
        interpretKeyEvents([theEvent])
    }
    
    override func deleteBackward(sender: AnyObject?) {
        let row = self.outlineView.selectedRow
        if row == -1 {
            return
        }
        if let item = self.outlineView.itemAtRow(row) {
            if let bookmark = item as? Bookmark {
                if let parent = bookmark.parent {
                    parent.removeBookmarkWithPage(bookmark.page)
                }
            }
        }
        self.outlineView.reloadData()
    }

    // when receive notification from delete button in the popup view:
    func deleteNoteItemWithNotification(note: NSNotification) {
        let itemInfo = note.userInfo! as! [String: NoteItem]
        if let item = itemInfo["noteItem"]{
            if let parent = item.parent {
                parent.removeSubnotesWithPageAndTitle(item.page, title: item.title)
            }
        }
        self.popover.close()
    }
    
    // MARK: - Popover
    // show popover at selected item
    func popoverWillShow(notification: NSNotification) {
        if isAdding {
            self.popoverViewController?.deleteButton.enabled = false
            self.popoverViewController?.noteTitle.stringValue = ""
            self.popoverViewController?.noteContent.string = ""
        } else if let item = self.editingNoteItem {
            self.popoverViewController?.deleteButton.enabled = true
            self.popoverViewController?.noteTitle.stringValue = item.title
            if let conent = item.content {
                self.popoverViewController?.noteContent.string = conent
            }
        }
    }
    
    func popoverWillClose(notification: NSNotification) {
        // get the current viewing pdf page
        let page = self.pdfSet!.getCurrentPage()
        // get the current note
        let note = self.notes[self.indexOfSelectedPDF]
        
        if let title = self.popoverViewController?.noteTitle.stringValue {
            let noteItem = NoteItem(page: page, title: title, parent: note)
            if let content = self.popoverViewController?.noteContent.string {
                noteItem.content = content
            }
            
            // when popup view is closing, do append or update depend on it is save or add
            if isAdding {
                note.insertSubnote(noteItem)
            } else {
                if let item = editingNoteItem {
                    note.updateSubnote(withitem: noteItem, orignalTitle: item.title, orignalPage: item.page)
                }
            }
        }
    }
    
    func popoverDidClose(notification: NSNotification) {
        self.outlineView.reloadData()
    }
    
    // MARK: - Search Functions
    @IBAction func search(sender: NSTextField) {
        if let set = self.pdfSet {
            self.outlineOption.selectItemAtIndex(2)
            self.outlineOptionSelect(self.outlineOption.selectedCell() as! NSPopUpButtonCell)
            
            for eachNote in self.notes {
                eachNote.resultGroup = []
            }
            for i in 0..<set.pdfDocuments.count {
                if let pdf = self.pdfSet?.pdfDocuments[i] {
                    self.indexOfNote = i
                    pdf.findString(sender.stringValue, withOptions: 1)
                }
            }
        }
    }
    
    func didBeginFind(note: NSNotification) {
        self.outlineView.reloadData()
    }
    
    func didEndFind(note: NSNotification) {
        self.outlineView.reloadData()
        for each in self.notes {
            self.outlineView.expandItem(each, expandChildren: true)
        }
    }
    
    override func didMatchString(instance: PDFSelection!) {
        self.notes[indexOfNote].addResultSelections(instance, parent: self.notes[indexOfNote])
    }
    
}