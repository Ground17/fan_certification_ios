//
//  fancertificationApp.swift
//  Shared
//
//  Created by 유지상 on 2021/11/28.
//

import SwiftUI
import Firebase

@main
struct fancertificationApp: App {
    @StateObject var viewModel = AuthenticationViewModel()
    
    init() {
        FirebaseApp.configure()
        
        if (Auth.auth().currentUser != nil) {
            viewModel.state = .signedIn
        } else {
            viewModel.state = .signedOut
        }
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
