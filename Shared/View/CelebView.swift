//
//  ListView.swift
//  fancertification
//
//  Created by 유지상 on 2022/04/13.
//

import SwiftUI
import GoogleMobileAds

struct CelebView: View {
    @EnvironmentObject var viewModel: DataViewModel
    
    var body: some View {
        VStack {
            GADBannerViewController()
                    .frame(width: GADAdSizeBanner.size.width, height: GADAdSizeBanner.size.height)
            List(self.viewModel.celeb, id: \.account) { celeb in
                //각 Row에 CarMakerCell를 리턴합니다.
                CelebCell(celeb: celeb)
            }
            Spacer()
        }
    }
}

struct CelebCell: View {
    @EnvironmentObject var viewModel: DataViewModel
    let celeb: Celeb

    var body: some View {
        HStack {
            Image(celeb.url)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .cornerRadius(25)

            VStack(alignment: .leading) {
                Text(celeb.title).font(.largeTitle)
                // Text(celeb.count)
                Text(celeb.since)
            }
            
            Button(action: {
                // 하트 추가
            }) {
                Image(celeb.url)
                    .resizable()
                    .frame(width: 50, height: 50)
            }
        }
    }
}

struct CelebView_Previews: PreviewProvider {
    static var previews: some View {
        CelebView()
    }
}
