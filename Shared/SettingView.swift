//
//  SettingView.swift
//  fancertification
//
//  Created by 유지상 on 2022/04/13.
//

import SwiftUI
import Firebase

struct SettingView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    
    var body: some View {
        Button(action: viewModel.signOut) {
            Text("Sign out")
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemIndigo))
                .cornerRadius(12)
                .padding()
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
