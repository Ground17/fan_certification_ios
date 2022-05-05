//
//  fancertificationApp.swift
//  Shared
//
//  Created by 유지상 on 2021/11/28.
//

import SwiftUI
import Firebase
import GoogleMobileAds

@main
struct fancertificationApp: App {
    @StateObject var authenticationViewModel = AuthenticationViewModel()
    @StateObject var dataViewModel = DataViewModel()
    
    init() {
        FirebaseApp.configure()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authenticationViewModel)
                .environmentObject(dataViewModel)
                .onAppear() {
                    authenticationViewModel.checkSignIn()
                }
        }
    }
}
