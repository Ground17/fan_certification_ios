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
        VStack {
            Text((Auth.auth().currentUser?.email) ?? "")
            Spacer()
            Button(action: viewModel.signOut) {
                Text("Sign out")
                    .foregroundColor(Color.white)
                    .frame(minWidth: 0, maxWidth: .infinity)
            }
            .padding()
            .background(Color("ColorPrimary"))
            .cornerRadius(5.0)
        }
        .padding()
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
