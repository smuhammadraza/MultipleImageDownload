//
//  DownloadingMultipleImagesViewController.swift
//  Tasks
//
//  Created by Muhammad Raza on 12/05/2021.
//

import UIKit

class DownloadingMultipleImagesViewController: UIViewController {

    // MARK: - OUTLETS
    @IBOutlet var imageViews: [UIImageView]!
    @IBOutlet var labelsProgress: [UILabel]!
    
    // MARK: - VARIABLES
    
    var imageURLs: [String] = [
        "https://i.pinimg.com/originals/af/8d/63/af8d63a477078732b79ff9d9fc60873f.jpg",
        "https://images.pexels.com/photos/1591447/pexels-photo-1591447.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
        "https://i.pinimg.com/564x/e9/29/1c/e9291cc39e820cd4afc6e58618dfc9e0.jpg"
    ]
    
    lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    // MARK: - VIEW LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - SETUP VIEW
    
    
    // MARK: - BUTTON ACTIONS
    
    @IBAction func didTapDownloadButton(_ sender: UIButton) {
        imageURLs.forEach { (url) in
            session.downloadTask(with: URL.init(string: url)!).resume()
        }
    }
    
    // MARK: - HELPER METHODS

}

extension DownloadingMultipleImagesViewController: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("downloadTask.taskIdentifier: \(downloadTask.taskIdentifier)")
        print("Original URL: \(String(describing: downloadTask.originalRequest!.url))")
        print("new location url: \(location)")
        DispatchQueue.main.async {
            if let imageData = NSData(contentsOf: location) {
                let image = UIImage(data: imageData as Data)
                self.imageViews[downloadTask.taskIdentifier-1].image = image
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let percent = Double(totalBytesWritten)/Double(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            self.labelsProgress[downloadTask.taskIdentifier-1].text = String(Float(percent))
        }
        print("downloadTask.taskIdentifier: \(downloadTask.taskIdentifier), Progress: \(Float(percent))")
    }
    
    
}
