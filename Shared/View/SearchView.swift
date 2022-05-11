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
                            // Dismiss the keyboard
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
                        .environmentObject(viewModel)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .navigationBarTitle("Search", displayMode: .inline)
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

struct ProfileCell: View {
    @EnvironmentObject var viewModel: DataViewModel
    let profile: Item

    var body: some View {
        HStack {
            URLImageView(withURL: profile.snippet.thumbnails.default.url)
                .padding(.leading)

            VStack(alignment: .leading) {
                Text(profile.snippet.title).bold()
                Text(profile.snippet.description).font(.caption)
                NavigationLink(destination: CustomWebView(url: "https://www.youtube.com/channel/\(profile.snippet.channelId)")) {
                    Text("Profile Link")
                        .font(.caption2)
                        .bold()
                        .foregroundColor(.red)
                }
            }
            .padding()
        }
        .onTapGesture {
            viewModel.showSearchConfirm = true
            print("The whole HStack is tappable now!")
        }
        .alert(isPresented: $viewModel.showSearchConfirm) {
            Alert(
                title: Text("Confirm"),
                message: Text("Are you sure you want to add this profile?"),
                primaryButton: .destructive(Text("Add"), action: {
                    // viewModel.manageFollow(platform: "0", account: profile.snippet.channelId, method: "Add", title: profile.snippet.title, url: profile.snippet.thumbnails.default.url)
                }), secondaryButton: .cancel())
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
