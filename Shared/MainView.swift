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
                    Image("star_outline")
                        .foregroundColor(Color("ColorPrimary"))
                    Text("Main")
                }

            SearchView()
                .tabItem {
                    Image("search")
                        .foregroundColor(Color("ColorPrimary"))
                    Text("Search")
                }
            
            SettingView()
                .tabItem {
                    Image("setting")
                        .foregroundColor(Color("ColorPrimary"))
                    Text("Setting")
                }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
