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
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
