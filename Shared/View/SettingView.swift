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
            Button(action: { viewModel.checkDeleteAccount = true }) {
                Text("Delete this account")
                    .foregroundColor(Color("ColorPrimary"))
                    .frame(minWidth: 0, maxWidth: .infinity)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(5.0)
            .alert(isPresented: $viewModel.checkDeleteAccount) {
                Alert(
                    title: Text("Confirm"),
                    message: Text("Are you sure you want to delete this account? This process is irreversible."),
                    primaryButton: .destructive(Text("Delete"), action: {
                        viewModel.deleteAccount()
                    }), secondaryButton: .cancel()
                )
            }
            Button(action: viewModel.signOut) {
                Text("Sign out")
                    .foregroundColor(Color.white)
                    .frame(minWidth: 0, maxWidth: .infinity)
            }
            .padding()
            .background(Color("ColorPrimary"))
            .cornerRadius(5.0)
            .padding(.bottom, 20)
        }
        .padding()
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
