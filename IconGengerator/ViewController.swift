//
//  ViewController.swift
//  IconGengerator
//
//  Created by mao li on 2020/12/8.
//

import Cocoa
import SnapKit
import Kingfisher


class ViewController: NSViewController {
    
    let iphoneSizes = [20, 29, 40, 60]
    let ipadSizes = [20, 29, 40, 76]
    let ipadPro = [83.5]
    let originSize = [1024]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dragDropView = DragDropView.init()
        dragDropView.layer?.backgroundColor = NSColor.orange.cgColor
        dragDropView.delegate = self
        view.addSubview(dragDropView)
        dragDropView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        
    }

    override var representedObject: Any? {
        didSet {}
    }

}

extension ViewController: DragDropViewDelegate {
    func dragDropViewFileDidReceived(list: [URL]?) {
        guard let list = list, !list.isEmpty else {
            return
        }
        
        guard let image = KFCrossPlatformImage.init(contentsOf: list.first!) else { return }
        for size in iphoneSizes {
            let processor2 = generateProcessors(scaleFactor: 2, edge: Float(size))
            createImage(processor: processor2, image: image, name: "\(size)×\(size)@2x")
            let processor3 = generateProcessors(scaleFactor: 3, edge: Float(size))
            createImage(processor: processor3, image: image, name: "\(size)×\(size)@3x")
        }
        
        for size in ipadSizes {
            let processor = generateProcessors(scaleFactor: 1, edge: Float(size))
            let processor2 = generateProcessors(scaleFactor: 2, edge: Float(size))
            createImage(processor: processor2, image: image, name: "\(size)×\(size)@2x")
            createImage(processor: processor, image: image, name: "\(size)×\(size)")
        }
        
        for size in ipadPro {
            let processor2 = generateProcessors(scaleFactor: 2, edge: Float(size))
            createImage(processor: processor2, image: image, name: "\(size)×\(size)@2x")
        }
        
        for size in originSize {
            let processor = generateProcessors(scaleFactor: 1, edge: Float(size))
            createImage(processor: processor, image: image, name: "\(size)×\(size)")
        }
    }
    
    func generateProcessors(scaleFactor: Float, edge: Float) -> ResizingImageProcessor {
        let finalEdge = CGFloat(edge * scaleFactor)
        let size = CGSize.init(width: finalEdge, height: finalEdge)
        return ResizingImageProcessor.init(referenceSize: size)
    }
    
    func createImage(processor: ResizingImageProcessor, image: KFCrossPlatformImage, name: String) {
        let info = KingfisherParsedOptionsInfo(KingfisherOptionsInfo.init())
        let finalImage = processor.process(item: ImageProcessItem.image(image), options: info)
        guard let cgImage = finalImage?.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return
        }
        
        let rep = NSBitmapImageRep.init(cgImage: cgImage)
        guard let data = rep.representation(using: .png, properties: [NSBitmapImageRep.PropertyKey : Any]()) else { return }
        
        guard let urlForDownload = FileManager.default.urls(for: FileManager.SearchPathDirectory.downloadsDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first else { return }
        let fileBaseUrl = createDir(name: "iOS", url: urlForDownload)
        self.createFile(name: name + ".png", fileBaseUrl: fileBaseUrl, data: data)
    }

    
   //根据文件名和路径创建文件
    func createFile(name:String, fileBaseUrl:URL, data: Data){
       let manager = FileManager.default
        
       let file = fileBaseUrl.appendingPathComponent(name)
       print("文件: \(file)")
       let exist = manager.fileExists(atPath: file.path)
       if !exist {
           let createSuccess = manager.createFile(atPath: file.path,contents:data,attributes:nil)
           print("文件创建结果: \(createSuccess)")
       } else {
//            try? manager.replaceItemAt(file, withItemAt: <#T##URL#>)
       }
   }
    
    func createDir(name: String, url: URL) -> URL {
        if url.absoluteString.existAtPath {
            print("文件夹已存在")
            return url
        } else {
            do {
                try FileManager.default.createDirectory(at: url.absoluteURL.appendingPathComponent(name),
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
                return url.absoluteURL.appendingPathComponent(name)
            } catch let error {
                print("创建文件夹失败")
            }
        }
        
        fatalError("文件夹异常")
    }
    
}

extension String {
    var existAtPath: Bool {
        return FileManager.default.fileExists(atPath: self)
    }
}
