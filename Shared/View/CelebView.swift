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
        NavigationView {
            VStack {
                GADBannerViewController()
                        .frame(width: GADAdSizeBanner.size.width, height: GADAdSizeBanner.size.height)
                List(self.viewModel.celeb, id: \.account) { celeb in
                    CelebCell(celeb: celeb)
                        .environmentObject(viewModel)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .navigationBarTitle("Main", displayMode: .inline)
            .navigationBarHidden(true)
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text("Alert"),
                    message: Text(viewModel.alertText),
                    dismissButton: .default(Text("OK"), action: {
                        viewModel.closeAlert()
                    })
                )
            }
        }
    }
}

struct CelebCell: View {
    @EnvironmentObject var viewModel: DataViewModel
    let celeb: Celeb
    
    @State private var isExpanding = false

    var body: some View {
        VStack {
            HStack {
                URLImageView(withURL: celeb.url)
                    .padding(.leading)
                
                Text(celeb.title)
                    .bold()
                Spacer()
                Image("arrow-up")
                    .padding(.trailing)
            }
            .padding()
            .onTapGesture {
                isExpanding = !isExpanding
                print("The whole HStack is tappable now!")
            }
            
            if isExpanding {
                VStack {
                    HStack {
                        Text("delete")
                        Spacer()
                        Text("refresh")
                        Text("launch")
                    }
                    HStack {
                        VStack { // 팬이 된 기간
                            Text("Period of being a fan")
                            Text("100 days")
                            Text("\(celeb.since)")
                        }
                        VStack { // 좋아요
                            Text("Likes")
                            Text("\(celeb.count)")
                            Text("\(celeb.recent)")
                        }
                    }
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
                .animation(.default)
            }
        }
        .alert(isPresented: $viewModel.showCelebConfirm) {
            Alert(
                title: Text("Comfirm"),
                message: Text(viewModel.alertText),
                primaryButton: .destructive(Text("Add"), action: {
                    
                }), secondaryButton: .cancel())
        }
    }
}

struct CelebView_Previews: PreviewProvider {
    static var previews: some View {
        CelebView()
    }
}
