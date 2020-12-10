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
        // 1 获取下载文件夹
        guard let urlForDownload = FileManager.default.urls(for: FileManager.SearchPathDirectory.downloadsDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first else { return }
        
        let superDir = createDir(name: "iOS", url: urlForDownload)
        let iconSet = createDir(name: "AppIcon.appiconset", url: superDir)
        let spec = Bundle.main.path(forResource: "Contents", ofType: "json")!
        do {
            try FileManager.default.copyItem(at: URL.init(fileURLWithPath: spec), to: iconSet.appendingPathComponent("Contents.json"))
        } catch let error {
            if error != nil {
                print(error.localizedDescription)
            }
        }
        
        guard let data = try? Data.init(contentsOf: URL.init(fileURLWithPath: spec)) else { return  }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String : Any] else { return }
        guard let imageItems = json["images"] as? [[String: String]] else { return }
        for item in imageItems {
            let lengthStr = String((item["size"]!).split(separator: "x").first ?? "")
            let len = CGFloat(truncating: NumberFormatter().number(from: lengthStr) ?? 0)
            let scaleStr = String(item["scale"]!.split(separator: "x").first ?? "")
            let scale = CGFloat(truncating: NumberFormatter().number(from: scaleStr) ?? 0)
            let filename = item["filename"] ?? ""
            guard let image = KFCrossPlatformImage.init(contentsOf: list.first!) else { return }
            createImage(processor: generateProcessors(scaleFactor: scale, edge: len), image: image, name: filename, url: iconSet)
        }
        
//        guard let image = KFCrossPlatformImage.init(contentsOf: list.first!) else { return }
//        for size in iphoneSizes {
//            let processor2 = generateProcessors(scaleFactor: 2, edge: Float(size))
//            createImage(processor: processor2, image: image, name: "\(size)×\(size)@2x")
//            let processor3 = generateProcessors(scaleFactor: 3, edge: Float(size))
//            createImage(processor: processor3, image: image, name: "\(size)×\(size)@3x")
//        }
//
//        for size in ipadSizes {
//            let processor = generateProcessors(scaleFactor: 1, edge: Float(size))
//            let processor2 = generateProcessors(scaleFactor: 2, edge: Float(size))
//            createImage(processor: processor2, image: image, name: "\(size)×\(size)@2x")
//            createImage(processor: processor, image: image, name: "\(size)×\(size)")
//        }
//
//        for size in ipadPro {
//            let processor2 = generateProcessors(scaleFactor: 2, edge: Float(size))
//            createImage(processor: processor2, image: image, name: "\(size)×\(size)@2x")
//        }
//
//        for size in originSize {
//            let processor = generateProcessors(scaleFactor: 1, edge: Float(size))
//            createImage(processor: processor, image: image, name: "\(size)×\(size)")
//        }
    }
    
    func generateProcessors(scaleFactor: CGFloat, edge: CGFloat) -> ResizingImageProcessor {
        let finalEdge = edge * scaleFactor
        let size = CGSize.init(width: finalEdge, height: finalEdge)
        return ResizingImageProcessor.init(referenceSize: size)
    }
    
    func createImage(processor: ResizingImageProcessor, image: KFCrossPlatformImage, name: String, url: URL) {
        let info = KingfisherParsedOptionsInfo(KingfisherOptionsInfo.init())
        let finalImage = processor.process(item: ImageProcessItem.image(image), options: info)
        guard let cgImage = finalImage?.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return
        }
        
        let rep = NSBitmapImageRep.init(cgImage: cgImage)
        guard let data = rep.representation(using: .png, properties: [NSBitmapImageRep.PropertyKey : Any]()) else { return }
//        guard let urlForDownload = FileManager.default.urls(for: FileManager.SearchPathDirectory.downloadsDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first else { return }
//        let fileBaseUrl = createDir(name: "iOS", url: urlForDownload)

        self.createFile(name: name, fileBaseUrl: url, data: data)
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
            try? FileManager.default.removeItem(at: url)
        }
        
        do {
            try FileManager.default.createDirectory(at: url.absoluteURL.appendingPathComponent(name),
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
            return url.absoluteURL.appendingPathComponent(name)
        } catch let error {
            print("创建文件夹失败")
            fatalError("文件夹异常")
        }
    }
}

extension String {
    var existAtPath: Bool {
        return FileManager.default.fileExists(atPath: self)
    }
}

struct ImageItem: Codable {
    var size: String
    var idiom: String
    var filename: String
    var scale: String
//    {
//        "size": "20x20",
//        "idiom": "iphone",
//        "filename": "icon-20@2x.png",
//        "scale": "2x"
//    }
}
