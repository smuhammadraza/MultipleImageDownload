//
//  Extension+UIImageView.swift
//  Tasks
//
//  Created by Muhammad Raza on 12/05/2021.
//

import UIKit

extension UIImageView {
    private func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleToFill) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    
    internal func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleToFill) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        let url = URL.init(fileURLWithPath: link)
        let imageData = try? Data.init(contentsOf: url, options: .mappedIfSafe)
        self.image = UIImage.init(data: imageData ?? Data())
//        downloaded(from: url, contentMode: mode)
    }
}


extension Data {   
    public var bytes: Array<UInt8> {
        return Array(self)
    }
}
