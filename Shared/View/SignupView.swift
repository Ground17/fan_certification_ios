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
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var id: String = ""
    @State private var pw: String = ""
    @State private var pwConfirm: String = ""
    @State private var showAlert: Bool = false
    
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
            SecureField("Enter your password", text: $pw)
                .padding()
                .autocapitalization(.none)
                .background(Color.gray)
                .cornerRadius(5.0)
            SecureField("Enter your password Again", text: $pwConfirm)
                .padding()
                .autocapitalization(.none)
                .background(Color.gray)
                .cornerRadius(5.0)
                .padding(.bottom, 20)
            Button(action: {
                viewModel.signUp(id: id, pw: pw, pwConfirm: pwConfirm, view: self) }) {
                Text("Sign up")
                    .foregroundColor(Color("ColorPrimary"))
                    .frame(minWidth: 0, maxWidth: .infinity)
            }
                .padding()
                .background(Color.white)
                .cornerRadius(5.0)
                .padding(.bottom, 20)
        }
        .padding()
        .navigationBarTitle("Sign up")
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
    }
}
