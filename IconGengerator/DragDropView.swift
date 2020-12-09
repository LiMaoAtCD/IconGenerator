//
//  DragDropView.swift
//  IconGengerator
//
//  Created by mao li on 2020/12/9.
//

import Cocoa

protocol DragDropViewDelegate: class {
    func dragDropViewFileDidReceived(list: [URL]?)
}

class DragDropView: NSView {
    
    weak var delegate: DragDropViewDelegate?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.registerForDraggedTypes([NSPasteboard.PasteboardType.fileURL])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let pasteBoard = sender.draggingPasteboard
        if let types = pasteBoard.types, types.contains(NSPasteboard.PasteboardType.fileURL) {
            return NSDragOperation.copy
        }
        return NSDragOperation.init()
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pBoard = sender.draggingPasteboard
        var fileUrl: URL?
        var fileList: [URL]?
        if let items = pBoard.pasteboardItems, items.count <= 1 {
            fileUrl = NSURL.init(from: pBoard) as URL?
            fileList = [fileUrl!]
        }
        self.delegate?.dragDropViewFileDidReceived(list: fileList)
        
        return true
    }
    
}
