//
//  RankView.swift
//  fancertification
//
//  Created by 유지상 on 2022/05/06.
//

import SwiftUI
import GoogleMobileAds

struct RankView: View {
    @EnvironmentObject var viewModel: DataViewModel
    var platforms = ["YouTube"]
    
    @State private var selectedIndex = 0
    var body: some View {
        NavigationView {
            VStack {
                GADBannerViewController()
                        .frame(width: GADAdSizeBanner.size.width, height: GADAdSizeBanner.size.height)
                Divider()
                Picker(selection: $selectedIndex, label: Text("Platform: ")) {
                    ForEach(0 ..< platforms.count) {
                        Text(self.platforms[$0])
                    }
                }
                if self.viewModel.loading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Spacer()
                } else {
                    HStack {
                        Text("The top 25 celebrities by likes are displayed.")
                            .padding()
                        Spacer()
                        Button(action: {
                            self.viewModel.getRank()
                        }) {
                            Text("refresh")
                                .padding()
                        }
                    }
                        
                    List(self.viewModel.rank, id: \.account) { rank in
                        RankCell(rank: rank)
                            .environmentObject(viewModel)
                    }
                }
            }
            .navigationBarTitle("Ranking")
            .navigationBarHidden(true)
//            .alert(isPresented: $viewModel.showAlert) {
//                Alert(
//                    title: Text("Alert"),
//                    message: Text(viewModel.alertText),
//                    dismissButton: .default(Text("OK"), action: {
//                        viewModel.closeAlert()
//                    })
//                )
//            }
        }
        .navigationViewStyle(.stack)
        .pickerStyle(SegmentedPickerStyle())
        .onAppear() {
            self.viewModel.getRank()
        }
    }
}

struct RankCell: View {
    @EnvironmentObject var viewModel: DataViewModel
    let rank: Rank
    
    @State private var isExpanding = false
    @State private var isWebView: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Text("#\(rank.rankNumber)")
                URLImageView(withURL: rank.url)
                    .padding(.leading)
                
                Text(rank.title)
                    .bold()
                Spacer()
                Text("♥ \(rank.count)")
                    .foregroundColor(Color.red)
                    .bold()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isExpanding.toggle()
                print("The whole HStack is tappable now!")
            }
            
            if isExpanding {
                VStack (alignment: .center) {
                    Divider()
                    HStack {
                        Image("youtube")
                            .foregroundColor(Color("ColorPrimary"))
                        Text("YouTube")
                            .padding()
                        Spacer()
                        Text("View profile")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.red)
                            .padding()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isWebView.toggle()
                    }
                    
                }
            }
        }
        .background(Group {
            NavigationLink(destination: CustomWebView(url: "https://www.youtube.com/channel/\(rank.account)"), isActive: $isWebView) {
                EmptyView()
            }
            .opacity(0)
        }.disabled(true))
    }
}

//struct RankView_Previews: PreviewProvider {
//    static var previews: some View {
//        RankView()
//    }
//}
