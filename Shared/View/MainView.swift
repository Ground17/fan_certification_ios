//
//  MainView.swift
//  fancertification
//
//  Created by 유지상 on 2022/04/13.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var viewModel: DataViewModel
    @State private var tabSelection = 0
    
    var body: some View {
        TabView (selection: $tabSelection) {
            CelebView(tabSelection: $tabSelection)
                .tabItem {
                    Image("star")
                        .foregroundColor(Color("ColorPrimary"))
                    Text("Main")
                }
                .tag(0)
            
            RankView()
                .tabItem {
                    Image("star_outline")
                        .foregroundColor(Color("ColorPrimary"))
                    Text("Ranking")
                }
                .tag(1)

            SearchView()
                .tabItem {
                    Image("search")
                        .foregroundColor(Color("ColorPrimary"))
                    Text("Search")
                }
                .tag(2)
            
            SettingView()
                .tabItem {
                    Image("setting")
                        .foregroundColor(Color("ColorPrimary"))
                    Text("Setting")
                }
                .tag(3)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
