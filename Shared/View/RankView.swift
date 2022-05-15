//
//  RankView.swift
//  fancertification
//
//  Created by 유지상 on 2022/05/06.
//

import SwiftUI

struct RankView: View {
    var platforms = ["YouTube"]
    
    @State private var selectedIndex = 0
    var body: some View {
        VStack {
            Picker(selection: $selectedIndex, label: Text("Platform: ")) {
                ForEach(0 ..< platforms.count) {
                    Text(self.platforms[$0])
                }
            }
            Spacer()
            Text("Getting ready...")
            Spacer()
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}

struct RankView_Previews: PreviewProvider {
    static var previews: some View {
        RankView()
    }
}
