//
//  MainView.swift
//  fancertification
//
//  Created by 유지상 on 2022/04/13.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var viewModel: DataViewModel
    
    var body: some View {
        TabView {
            CelebView()
                .tabItem {
                    Image("star")
                        .foregroundColor(Color("ColorPrimary"))
                    Text("Main")
                }
            
            RankView()
                .tabItem {
                    Image("star_outline")
                        .foregroundColor(Color("ColorPrimary"))
                    Text("Ranking")
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
