//
//  ListView.swift
//  fancertification
//
//  Created by 유지상 on 2022/04/13.
//

import SwiftUI
import GoogleMobileAds

struct CelebView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    
    var body: some View {
        GADBannerViewController()
                .frame(width: GADAdSizeBanner.size.width, height: GADAdSizeBanner.size.height)
    }
}

struct CelebView_Previews: PreviewProvider {
    static var previews: some View {
        CelebView()
    }
}
