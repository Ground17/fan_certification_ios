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
    @Binding var tabSelection: Int
    
    @State var currentDate = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            VStack {
                GADBannerViewController()
                        .frame(width: GADAdSizeBanner.size.width, height: GADAdSizeBanner.size.height)
                Divider()
                if self.viewModel.loading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Spacer()
                } else {
                    if self.viewModel.celeb.isEmpty {
                        Button(action: {
                            self.tabSelection = 2
                        }) {
                            Text("You can search celebrity in YouTube!")
                        }
                        Spacer()
                    } else {
                        HStack {
                            Text("\(viewModel.dateFormatter.string(from: currentDate))")
                                .padding()
                                .onReceive(timer) { input in
                                    currentDate = input
                                }
                            Spacer()
                            Button(action: {
                                self.viewModel.getCeleb()
                            }) {
                                Text("refresh")
                                    .padding()
                            }
                        }
                        
                        List(self.viewModel.celeb, id: \.account) { celeb in
                            CelebCell(celeb: celeb)
                                .environmentObject(viewModel)
                        }
                    }
                }
            }
            .navigationBarTitle("Main")
            // .navigationBarHidden(true)
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
        .navigationViewStyle(.stack)
        .onAppear() {
            self.viewModel.getCeleb()
            self.viewModel.initFormatter()
        }
    }
}

struct CelebCell: View {
    @EnvironmentObject var viewModel: DataViewModel
    let celeb: Celeb
    
    @State private var isExpanding = false
    @State private var isWebView: Bool = false

    var body: some View {
        VStack {
            HStack {
                URLImageView(withURL: celeb.url)
                    .padding(.leading)
                
                Text(celeb.title)
                    .bold()
                Spacer()
                Image("arrow-up")
                    .frame(width: 32, height: 37, alignment: .center)
                    .aspectRatio(contentMode: ContentMode.fit)
                    .rotationEffect(.degrees(isExpanding ? 180 : 0))
                    .animation(.default)
                    .padding(.trailing, 10)
            }
            .onTapGesture {
                isExpanding.toggle()
                print("The whole HStack is tappable now!")
            }
            
            if isExpanding {
                VStack (alignment: .center) {
                    Divider()
                    HStack {
                        Text("delete")
                            .onTapGesture {
                                viewModel.platform = celeb.platform
                                viewModel.account = celeb.account
                                viewModel.showCelebDeleteConfirm = true
                            }
                            .alert(isPresented: $viewModel.showCelebDeleteConfirm) {
                                Alert(
                                    title: Text("Comfirm"),
                                    message: Text("Are you sure you want to delete this user?"),
                                    primaryButton: .destructive(Text("Delete"), action: {
                                        viewModel.manageFollow(platform: viewModel.platform, account: viewModel.account, method: "delete", title: nil, url: nil)
                                    }), secondaryButton: .cancel())
                        }
                        Spacer()
                        Text("refresh")
                            .onTapGesture {
                                viewModel.platform = celeb.platform
                                viewModel.account = celeb.account
                                viewModel.showCelebUpdateConfirm = true
                            }
                            .alert(isPresented: $viewModel.showCelebUpdateConfirm) {
                                Alert(
                                    title: Text("Comfirm"),
                                    message: Text("Are you sure you want to refresh this user?"),
                                    primaryButton: .destructive(Text("Refresh"), action: {
                                        viewModel.getYTChannel(query: viewModel.account, update: true)
                                    }), secondaryButton: .cancel())
                        }
                    }
                    Divider()
                    HStack (spacing: 0) {
                        VStack (alignment: .center) { // 팬이 된 기간
                            Text("Period")
                                .fontWeight(.bold)
                                .foregroundColor(Color(red: 237 / 255, green: 96 / 255, blue: 91 / 255))
                            Text("\(viewModel.calDates(since: celeb.since))")
                                .font(.title)
                                .foregroundColor(Color(red: 237 / 255, green: 96 / 255, blue: 91 / 255))
                            Text("since: \(viewModel.dateFormatter.string(from: celeb.since))")
                                .font(.caption)
                                .foregroundColor(Color(red: 237 / 255, green: 96 / 255, blue: 91 / 255))
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .background(Color(red: 252 / 255, green: 240 / 255, blue: 240 / 255).clipShape(RoundedRectangle(cornerRadius: 5.0)))
                        .padding(.trailing)
                        
                        VStack (alignment: .center) { // 좋아요
                            Text("Likes ♥")
                                .fontWeight(.bold)
                                .foregroundColor(Color(red: 133 / 255, green: 93 / 255, blue: 246 / 255))
                            Text("\(celeb.count)")
                                .font(.title)
                                .foregroundColor(Color(red: 133 / 255, green: 93 / 255, blue: 246 / 255))
                            Text("last: \(viewModel.dateFormatter.string(from: celeb.recent))")
                                .font(.caption)
                                .foregroundColor(Color(red: 133 / 255, green: 93 / 255, blue: 246 / 255))
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .background(Color(red: 244 / 255, green: 240 / 255, blue: 254 / 255).clipShape(RoundedRectangle(cornerRadius: 5.0)))
                        .onTapGesture {
                            viewModel.platform = celeb.platform
                            viewModel.account = celeb.account
                            viewModel.showCelebCountConfirm = true
                            print("The VStack is tappable now!")
                        }
                        .alert(isPresented: $viewModel.showCelebCountConfirm) {
                            Alert(
                                title: Text("Comfirm"),
                                message: Text("Are you sure you want to add likes of this user?"),
                                primaryButton: .destructive(Text("Add"), action: {
                                    viewModel.addHeart(platform: viewModel.platform, account: viewModel.account)
                                }), secondaryButton: .cancel())
                        }
                        .padding(.trailing)
                    }
                    .padding()
                    .transition(.move(edge: .bottom))
                    .animation(.default)
                    
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
                        self.isWebView = true
                    }
                    
                }
            }
        }
        .background(Group {
            NavigationLink(destination: CustomWebView(url: "https://www.youtube.com/channel/\(celeb.account)"), isActive: $isWebView) {
                EmptyView()
            }
            .opacity(0)
        }.disabled(true))
//        .alert(isPresented: $viewModel.showCelebProfileConfirm) {
//            Alert(
//                title: Text("Comfirm"),
//                message: Text("Go to \(celeb.title)'s YouTube profile by launching YouTube app or another browser app. Would you like to go on?"),
//                primaryButton: .destructive(Text("Go"), action: {
//                    guard let url = URL(string: "https://www.youtube.com/channel/\(viewModel.account)") else {
//                        viewModel.showAlert = true
//                        viewModel.alertText = "Internal app error..."
//                        return
//                    }
//                    UIApplication.shared.open(url)
//                }), secondaryButton: .cancel())
//        }
    }
}

//struct CelebView_Previews: PreviewProvider {
//    static var previews: some View {
//        CelebView(tabSelection: 0)
//    }
//}
