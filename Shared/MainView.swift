//
//  MainView.swift
//  fancertification
//
//  Created by 유지상 on 2022/04/13.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            CelebView()
                .tabItem {
                    Image(systemName: "star_outline")
                }

            SearchView()
                .tabItem {
                    Image(systemName: "search")
                }
            
            SettingView()
                .tabItem {
                    Image(systemName: "setting")
                }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
