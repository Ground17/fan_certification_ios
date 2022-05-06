//
//  ImageLoader.swift
//  fancertification
//
//  Created by 유지상 on 2022/05/06.
//

import UIKit

class ImageLoader: ObservableObject {
    @Published var image: UIImage = UIImage()
    
    init(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.image = UIImage(data: data) ?? UIImage()
            }
        }
        task.resume()
    }
}
