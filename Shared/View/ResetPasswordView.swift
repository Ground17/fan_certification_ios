//
//  ResetPasswordView.swift
//  fancertification
//
//  Created by 유지상 on 2022/05/30.
//

import SwiftUI

struct ResetPasswordView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var id: String = ""
    @State private var pw: String = ""
    @State private var isSignUp: Bool = false
    @State private var showAlert: Bool = false
    
    @State var currentNonce: String? // apple login에만 필요
    
    var body: some View {
        VStack {
            Image("MainLogo")
                .resizable()
                .aspectRatio(contentMode: ContentMode.fit)
            TextField("Enter your email", text: $id)
                .padding()
                .autocapitalization(.none)
                .background(Color.gray)
                .cornerRadius(5.0)
                .padding(.top, 20)
            Button(action: { viewModel.resetPasssword(id: id, view: self) }) {
                Text("Send Password Reset Email")
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

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView()
    }
}
