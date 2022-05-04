//
//  SignupView.swift
//  fancertification
//
//  Created by 유지상 on 2022/05/03.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct SignupView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    
    @State private var id: String = ""
    @State private var pw: String = ""
    @State private var pwConfirm: String = ""
    
    var body: some View {
        VStack {
            Image("MainLogo")
                .resizable()
                .aspectRatio(contentMode: ContentMode.fit)
            TextField("Enter your email", text: $id)
            SecureField("Enter your password", text: $pw)
            SecureField("Enter your password Again", text: $pwConfirm)
            Button(action: { viewModel.signUp(id: id, pw: pw, pwConfirm: pwConfirm) }) {
                Text("Sign up")
            }
        }
        .padding()
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
    }
}
