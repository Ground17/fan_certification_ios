//
//  SearchView.swift
//  fancertification
//
//  Created by 유지상 on 2022/04/13.
//

import SwiftUI

struct SearchView: View { // webview로 확인
    @EnvironmentObject var viewModel: DataViewModel
    
    var platforms = ["YouTube"]
    
    @State private var selectedIndex = 0
    @State private var searchText = ""
    @State private var isEditing = false
    
    var body: some View {
        NavigationView {
            VStack {
                Picker(selection: $selectedIndex, label: Text("Platform: ")) {
                    ForEach(0 ..< platforms.count) {
                        Text(self.platforms[$0])
                    }
                }
                HStack {
                    TextField("Search...", text: $searchText)
                        .padding(7)
                        .padding(.horizontal, 25)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .overlay(
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 8)
                         
                                if isEditing {
                                    Button(action: {
                                        self.searchText = ""
                                    }) {
                                        Image(systemName: "multiply.circle.fill")
                                            .foregroundColor(.gray)
                                            .padding(.trailing, 8)
                                    }
                                }
                            }
                        )
                        .padding(.horizontal, 10)
                        .onTapGesture {
                            self.isEditing = true
                        }
         
                    if isEditing {
                        Button(action: {
                            self.isEditing = false
                            viewModel.getYTChannel(query: searchText)
                        }) {
                            Text("Submit")
                        }
                        .padding(.trailing, 10)
                        .transition(.move(edge: .trailing))
                        .animation(.default)
                    }
                }
                List(viewModel.items, id: \.snippet.channelId) { item in
                    ProfileCell(profile: item)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
}

struct ProfileCell: View {
    @EnvironmentObject var viewModel: DataViewModel
    let profile: Item

    var body: some View {
        HStack {
            Image(profile.snippet.thumbnails.default.url)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .cornerRadius(25)

            VStack(alignment: .leading) {
                Text(profile.snippet.title).font(.largeTitle)
                Text(profile.snippet.description)
            }
            
            NavigationLink(destination: CustomWebView(url: "https://www.youtube.com/channel/\(profile.snippet.channelId)")) {
                Text("Profile Link")
                    .edgesIgnoringSafeArea(.all)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.black)
                    .cornerRadius(20, antialiased: true)
            }
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("Alert"),
                message: Text(viewModel.alertText),
                primaryButton: .destructive(Text("Add"), action: {
                    
                }), secondaryButton: .cancel())
        }
        .onTapGesture {
            print("The whole HStack is tappable now!")
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
