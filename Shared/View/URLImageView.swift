//
//  URLImageView.swift
//  fancertification
//
//  Created by 유지상 on 2022/05/06.
//

import SwiftUI

struct URLImageView: View {
    @ObservedObject var imageLoader: ImageLoader
    @State var image: UIImage = UIImage()

    init(withURL url:String) {
        imageLoader = ImageLoader(urlString: url)
    }

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 50, height: 50)
            .cornerRadius(25)
            .onReceive(imageLoader.$image) { data in
                self.image = data
            }
    }
}
