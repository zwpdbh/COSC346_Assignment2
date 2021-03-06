//
//  MainWindowController.swift
//  PDFViewer
//
//  Created by zwpdbh on 9/28/16.
//  Copyright © 2016 Otago. All rights reserved.
//

import Cocoa
import Quartz

//public protocol MainWindowErrorDelegate {
//    func updateError(error: String)
//}

class MainWindowController: NSWindowController, PDFViewerDelegate, NSOutlineViewDataSource, NSOutlineViewDelegate, NSPopoverDelegate {

    // MARK: - Outlets and Actions
    @IBAction func createAboutWindow(_ sender: NSMenuItem) {
        let aboutWindowController = AboutWindowController()
        aboutWindowController.showWindow(self)
        self.aboutWindowController = aboutWindowController
    }
    
    @IBAction func createNewMainWindow(_ sender: NSMenuItem) {
        if !self.isMainWindowOpening {
            let mainWindowController = MainWindowController()
            mainWindowController.showWindow(self)
            self.mainWindowController = mainWindowController
            self.newMainWindowButton.isHidden = false;
        }
    }
    
    @IBOutlet weak var currentPageDisplay: NSTextField!
    
    @IBOutlet weak var newMainWindowButton: NSMenuItem!
    
    @IBOutlet weak var pdfView: PDFView!
    
    @IBOutlet weak var addNoteButton: NSButton!
    
    @IBOutlet weak var outlineView: NSOutlineView!
    
    @IBOutlet weak var outlineOption: NSPopUpButton!
    
    @IBOutlet weak var searchTextField: NSTextField!
    
    // update the outlineView column header when user select different option
    @IBAction func outlineOptionSelect(_ sender: NSPopUpButtonCell) {
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
    
    @IBAction func addBookmark(_ sender: NSButton) {
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
    
    @IBAction func addNote(_ sender: NSButton) {
        if let _ = self.pdfSet {
            // show popover when click addnote button
            isAdding = true
            self.popoverViewController?.isAdding = isAdding
            popover.show(relativeTo: self.addNoteButton.bounds, of: self.addNoteButton, preferredEdge: NSRectEdge.minY)
        }
    }
    @IBAction func saveNotes(_ sender: NSMenuItem) {
        // should save all notes under the same direcotry with pdfs
        for eachNote in self.notes {
            if let savingURL = getNoteURLFromPDFURL(eachNote.pdfURL as URL).path {
                let result = NSKeyedArchiver.archiveRootObject(eachNote, toFile: savingURL)
                if result {
                    print("save note succeed, at: " + savingURL)
                } else {
                    print("save note failed, when try to save note at: " + savingURL)
                }
            }
        }
    }
    
    // An helper method for generating saving note NSURL from PDF's NSURL
    func getNoteURLFromPDFURL(_ url: URL) -> URL {
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
        
        return URL(fileURLWithPath: savingURL)
    }
    
    // open a panel to load Notes, meanwhile trying to load associated PDFs
    @IBAction func openNotes(_ sender: NSMenuItem) {
        // open notes and load associated files
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["note"]
        panel.allowsMultipleSelection = true;
        
        panel.begin { (result) in
            if result == NSFileHandlingPanelOKButton {
                self.pdfSet = nil
                var pdfURLs: Array<URL> = []
                self.notes = []
                
                var invalidURLs = Array<URL>()
                
                for url in panel.urls {
                    if let note = NSKeyedUnarchiver.unarchiveObject(withFile: url.path) as? Note {
                        var error: NSError?
                        if (note.pdfURL as NSURL).checkResourceIsReachableAndReturnError(&error) {
                            self.notes.append(note)
                            pdfURLs.append(note.pdfURL as URL)
                        } else {
                            invalidURLs.append(note.pdfURL as URL)
                        }
                    }
                }
                // if found errors when try to load associated PDFs, use TableView to show the message
                if invalidURLs.count > 0 {
                    // create a window to alert user!
                    let errorWindowController = ErrorWindowController()
                    errorWindowController.showWindow(self)
                    self.errorWindowController = errorWindowController
        
                    self.errorWindowController!.updateError(invalidURLs: invalidURLs as Array<NSURL>)
                }
                
                // if found any associated PDF, load it into PDF model
                if pdfURLs.count > 0 {
                    self.pdfSet = PDFSet(pdfURLS: pdfURLs as Array<NSURL>)
                }
                if let set = self.pdfSet {
                    for url in set.addresses {
                        self.selectPDFButton.addItem(withTitle: url.lastPathComponent!)
                    }
                    // set PDFSet's delegate as MainWindowController
                    set.setPDFDocumentsDelegate(self)
                    set.delegate = self
                    self.pdfView.document = set.moveToGivenPDF(0)
                }
                self.outlineView.reloadData()
            }
        }
    }
    
    @IBOutlet weak var selectPDFButton: NSPopUpButton!
    
    // MARK: - Action
    // open panel to load PDFs
    @IBAction func openFile(_ sender: NSMenuItem) {
    
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true;
        panel.allowedFileTypes = ["pdf"]
        
        panel.begin { (result) in
            if(result == NSFileHandlingPanelOKButton) {
                // if load PDFs succeed, reset all PDF data and reset PDF selection button
                self.selectPDFButton.removeAllItems()
                self.pdfSet = PDFSet(pdfURLS: panel.urls as Array<NSURL>)
                
                // one pdf file for one note, if there has been a note with current pdf, then load it, 
                // otherwise, create a new one with pdf' url
                self.notes = Array<Note>()
                
                if let set = self.pdfSet {
                    for url in set.addresses {
                        self.selectPDFButton.addItem(withTitle: url.lastPathComponent!)
                        // if want associated Note, load it
                        if let note = self.getNoteFromURL(url as URL) {
                            self.notes.append(note)
                        } else {
                            // else create a new Note
                            self.notes.append(Note(url: url))
                        }
                    }
                    
                    set.setPDFDocumentsDelegate(self)
                    set.delegate = self
                    self.pdfView.document = set.moveToGivenPDF(0)
                }
                self.outlineView.reloadData()
            }
        }
    }
    
    // a helper method to try to load Note when open a PDF by using PDF's NSURL
    func getNoteFromURL(_ pdfURL: URL) -> Note? {
        let noteURL = getNoteURLFromPDFURL(pdfURL)
        var error: NSError?
        let noteExist = (noteURL as NSURL).checkResourceIsReachableAndReturnError(&error)
        if noteExist {
            return NSKeyedUnarchiver.unarchiveObject(withFile: noteURL.path) as? Note
        } else {
            return nil
        }
    }
    
    // go to previous page
    @IBAction func previousPage(_ sender: NSButton) {
        if let set = self.pdfSet {
            if let page = set.moveToPreviousPage() {
                self.pdfView.go(to: page)
            }
        }
    }
    
    
    // go to the next page
    @IBAction func nextPage(_ sender: NSButton) {
        if let set = self.pdfSet {
            if let page = set.moveToNextPage() {
                self.pdfView.go(to: page)
            }
        }
    }
    
    // go to the Given page
    @IBAction func goToGivenPage(_ sender: NSTextField) {
        if let set = self.pdfSet {
            if let pageNumber = Int(sender.stringValue) {
                if let page = set.moveToGivenPage(pageNumber) {
                    self.pdfView.go(to: page)
                }
            }
        }
    }
    
    // if there is not one pdf, then click this can go to previous one
    @IBAction func goToPreviousPDF(_ sender: NSButton) {
        if let set = self.pdfSet {
            if let pdf = set.moveToPreviousPDF() {
                self.pdfView.document = pdf
            }
        }

    }
    
    // if there is not one pdf, then click this can to to next one
    @IBAction func goToNextPDF(_ sender: NSButton) {
        if let set = self.pdfSet {
            if let pdf = set.moveToNextPDF() {
                self.pdfView.document = pdf
            }
        }
    }
    
    // move to selected pdf
    @IBAction func selectPDF(_ sender: NSPopUpButtonCell) {
        if let set = self.pdfSet {
            let selectedIndex = self.selectPDFButton.indexOfSelectedItem
            if let pdf = set.moveToGivenPDF(selectedIndex) {
                self.pdfView.document = pdf
            }
        }
        
    }
    
    @IBAction func zoomIn(_ sender: NSButton) {
        self.pdfView.zoomIn(sender)
    }
    
    @IBAction func zoomOut(_ sender: NSButton) {
        self.pdfView.zoomOut(sender)
    }
    
    @IBAction func resetZoom(_ sender: NSButton) {
        self.pdfView.autoScales = true
    }
    
    // MARK: - Model Variables
    
    var pdfSet: PDFSet?
    var notes: Array<Note> = []
    
    // use this index to put search result into separete note
    var indexOfNote: Int = 0
    
    var indexOfSelectedPDF = 1
    
    // 0 means viewing bookmarks, 1 means viewing notes, 2 means viewing search result
    var selectedOutLineOption = 0
    
    let popover = NSPopover()
    var popoverViewController : PopoverViewController?
    
    // it indicates whether a popover view is used for adding a new note or editing a existing note
    var isAdding: Bool =  true
    
    // it is the current editing NoteItem, which is the NoteItem when user click a row at outlineView
    var editingNoteItem: NoteItem?
    
    // it is the NoteItem populate the popover view when user is doing adding or updating
    var operatingNoteItem: NoteItem?
    
    
    var aboutWindowController: AboutWindowController?
    var errorWindowController: ErrorWindowController?
    var mainWindowController: MainWindowController?
    
    var isMainWindowOpening: Bool = false
    
    // MARK: - Action Related to Window
    func windowDidResize(_ notification: Notification) {
        self.pdfView.autoScales = true
    }
    
    func mainWindowDidClose(_ notice: Notification) {
        if let object = notice.object {
            if String(describing: type(of: (object) as AnyObject)) == "NSKVONotifying_NSWindow" {
                isMainWindowOpening = false
                self.newMainWindowButton.isHidden = false
            }
        }
    }

    override var windowNibName: String? {
        return "MainWindowController"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.isMainWindowOpening = true
        self.newMainWindowButton.isHidden = true
        
        // setup Notification for MainWindow
        NotificationCenter.default.addObserver(self, selector: #selector(mainWindowDidClose(_:)), name: NSNotification.Name.NSWindowWillClose, object: nil)
        
        // setup Notification for scroll of pages
        NotificationCenter.default.post(name: NSNotification.Name.PDFViewPageChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pageChangedAfterScroll), name: NSNotification.Name.PDFViewPageChanged, object: nil)
        
        // setup Notification for delete action on popover view
        NotificationCenter.default.addObserver(self, selector: #selector(deleteNoteItemWithNotification), name: NSNotification.Name(rawValue: "DeleteNoteItemFromPopupViewNotification"), object: nil)
        
        // set up popover controller
        self.popoverViewController = PopoverViewController(nibName: "PopoverViewController", bundle: nil)!
        self.popover.contentViewController = self.popoverViewController
        self.popover.behavior = NSPopoverBehavior.transient
        self.popover.delegate = self
        
        // setup Notifications for search
        NotificationCenter.default.addObserver(self, selector: #selector(didBeginFind), name: NSNotification.Name.PDFDocumentDidBeginFind, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEndFind), name: NSNotification.Name.PDFDocumentDidEndFind, object: nil)
        
        // Set up introductory startup page to your application
        if let path = Bundle.main.path(forResource: "introductory", ofType: "pdf") {
            let startUpPDFURL = URL(fileURLWithPath: path)
            var error: NSError?
            if (startUpPDFURL as NSURL).checkResourceIsReachableAndReturnError(&error) {
                self.pdfSet = PDFSet(pdfURLS: [startUpPDFURL])
                // one pdf file for one note, reset notes
                self.notes = Array<Note>()
                if let set = self.pdfSet {
                    for url in set.addresses {
                        self.selectPDFButton.addItem(withTitle: url.lastPathComponent!)
                        if let note = self.getNoteFromURL(url as URL) {
                            self.notes.append(note)
                        } else {
                            self.notes.append(Note(url: url))
                        }
                    }
                    set.setPDFDocumentsDelegate(self)
                    set.delegate = self
                    self.pdfView.document = set.moveToGivenPDF(0)
                }
                self.outlineView.reloadData()
            } else {
                print(startUpPDFURL)
            }
        }


    }
    
    // Recieve notification: update view, set current pdf to certain page, and update current page info
    func pageChangedAfterScroll() {
        if let page = self.pdfView.currentPage {
            self.pdfSet!.setPage(page)
        }
    }
    
    // MARK: - PDFSetDelegate A self defined protocol to sync info
    func pdfInfoNeedChangeTo(_ nthPDF: Int, totalPDFs: Int, title: String, page: Int, totalPages: Int) {
        self.window?.title = "\(nthPDF)/\(totalPDFs)_" + title
        self.currentPageDisplay.stringValue = "\(page)/\(totalPages)"
        self.indexOfSelectedPDF = nthPDF - 1
        self.selectPDFButton.selectItem(at: nthPDF - 1)
    }
    
    

    // MARK: - NSOutlineViewDataSource
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
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
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
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
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
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
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
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
    func outlineViewSelectionDidChange(_ notification: Notification) {
        let row = self.outlineView.selectedRow
        if let item = self.outlineView.item(atRow: row) {
            if let bookmark = item as? Bookmark {
                if let parent = bookmark.parent {
                    let pdfIndex = self.pdfSet?.getIndexByTitle(parent.title)
                    
                    // simulate select popup button
                    self.selectPDFButton.selectItem(at: Int(pdfIndex!))
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
                    self.selectPDFButton.selectItem(at: Int(pdfIndex!))
                    self.selectPDF(self.selectPDFButton.selectedCell() as! NSPopUpButtonCell)
                    // simulate go to a given page
                    self.currentPageDisplay.stringValue = "\(noteItem.page)"
                    self.goToGivenPage(self.currentPageDisplay)
                    
                    // record the noteitem which will be changed
                    editingNoteItem = noteItem
                    popover.show(relativeTo: self.outlineView.frameOfOutlineCell(atRow: row), of: self.outlineView.view(atColumn: 0, row: row, makeIfNecessary: false)!, preferredEdge: NSRectEdge.minY)
                    
                    let noteItemInfo = ["noteItem": noteItem]
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "AboutToEditNoteItemNotification"), object: self, userInfo: noteItemInfo as [AnyHashable: Any])
                }
            } else if let searchResult = item as? SearchResult {
                if let parent = searchResult.parent {
                    let pdfIndex = self.pdfSet?.getIndexByTitle(parent.title)
                    
                    // simulate select popup button
                    self.selectPDFButton.selectItem(at: Int(pdfIndex!))
                    self.selectPDF(self.selectPDFButton.selectedCell() as! NSPopUpButtonCell)
                }
                if let selection = searchResult.results.first {
                    if let page = selection.pages.first as? PDFPage {
                        if let pageNumber = Int(page.label) {
                            
                            // simulate go to a given page
                            self.currentPageDisplay.stringValue = "\(pageNumber)"
                            self.goToGivenPage(self.currentPageDisplay)
                            self.pdfView.currentSelection = selection
                            self.pdfView.scrollSelectionToVisible(self)
                        }
                    }
                }
            }
        }
    }
    
    
    // MARK: - key event
    override func keyDown(with theEvent: NSEvent) {
        interpretKeyEvents([theEvent])
    }
    
    // key action for deleting bookmark
    override func deleteBackward(_ sender: Any?) {
        let row = self.outlineView.selectedRow
        if row == -1 {
            return
        }
        if let item = self.outlineView.item(atRow: row) {
            if let bookmark = item as? Bookmark {
                if let parent = bookmark.parent {
                    parent.removeBookmarkWithPage(bookmark.page)
                }
            }
        }
        self.outlineView.reloadData()
    }

    // when receive notification from delete button in the popover view:
    func deleteNoteItemWithNotification(_ note: Notification) {
        if isAdding {
            self.popover.close()
            return
        }
        
        let itemInfo = (note as NSNotification).userInfo! as! [String: NoteItem]
        if let item = itemInfo["noteItem"]{
            if let parent = item.parent {
                parent.removeSubnotesWithPageAndTitle(item.page, title: item.title)
            }
        }
        self.popover.close()
    }
    
    // MARK: - Popover Control
    // show popover at selected item
    func popoverWillShow(_ notification: Notification) {
        self.popoverViewController?.errorInfor.stringValue = ""
    
        if isAdding {
            self.popoverViewController?.noteTitle.stringValue = ""
            self.popoverViewController?.noteContent.string = ""
        } else if let item = self.editingNoteItem {
            self.popoverViewController?.noteTitle.stringValue = item.title
            if let conent = item.content {
                self.popoverViewController?.noteContent.string = conent
            }
        }
    }
    
    // add or save NoteItem when popover view is closing
    func popoverWillClose(_ notification: Notification) {
        // get the current note
        let note = self.notes[self.indexOfSelectedPDF]

        if let noteItem = self.operatingNoteItem {
            if isAdding {
                note.insertSubnote(noteItem)
            } else {
                if let item = editingNoteItem {
                    note.updateSubnote(withitem: noteItem, orignalTitle: item.title, orignalPage: item.page)
                }
            }
        }
    }
    
    // befor closing popover view, validate data
    func popoverShouldClose(_ popover: NSPopover) -> Bool {
        self.operatingNoteItem = nil
        // get the current viewing pdf page
        let page = self.pdfSet!.getCurrentPage()
        // get the current note
        let note = self.notes[self.indexOfSelectedPDF]
        
        if let title = self.popoverViewController?.noteTitle.stringValue {
            self.operatingNoteItem = NoteItem(page: page, title: title, parent: note)
            if let content = self.popoverViewController?.noteContent.string {
                self.operatingNoteItem!.content = content
            }
            
            let validate = note.isValidated(self.operatingNoteItem!, isAdding: isAdding, exceptTitle: editingNoteItem?.title)
            
            if  !validate{
                self.popoverViewController?.errorInfor.textColor = NSColor.red
                self.popoverViewController?.errorInfor.stringValue = "title can not be empty and should be unqie at one page."
            } else {
                self.popoverViewController?.errorInfor.stringValue = ""
            }
            
            return validate
        }
        return true
    }
    
    // a selector for reload outlineView data when popover view cloded
    func popoverDidClose(_ notification: Notification) {
        self.outlineView.reloadData()
    }
    
    // MARK: - Search Functions
    @IBAction func search(_ sender: NSTextField) {
        if let set = self.pdfSet {
            self.outlineOption.selectItem(at: 2)
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
    
    // selector for notification: search begin
    func didBeginFind(_ note: Notification) {
        self.outlineView.reloadData()
    }
    
    // selector for notification: search end
    func didEndFind(_ note: Notification) {
        self.outlineView.reloadData()
        for each in self.notes {
            self.outlineView.expandItem(each, expandChildren: true)
        }
    }
    
    // selector for notification: find a matched String
    override func didMatchString(_ instance: PDFSelection) {
        self.notes[indexOfNote].addResultSelections(instance, parent: self.notes[indexOfNote])
    }
    
}
