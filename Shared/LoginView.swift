//
//  LoginView.swift
//  fancertification
//
//  Created by 유지상 on 2022/04/13.
//

import SwiftUI
import Firebase
import FirebaseAuth
import AuthenticationServices
import CryptoKit

struct LoginView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    
    @State private var id: String = ""
    @State private var pw: String = ""
    @State private var isSignUp: Bool = false
    @State private var showAlert: Bool = false
    
    @State var currentNonce: String? // apple login에만 필요
    
    var body: some View {
        NavigationView {
            VStack {
                Image("MainLogo")
                    .resizable()
                    .aspectRatio(contentMode: ContentMode.fit)
                TextField("Enter your email", text: $id)
                    .padding()
                    .background(Color.gray)
                    .cornerRadius(5.0)
                    .padding(.top, 20)
                SecureField("Enter your password", text: $pw)
                    .padding()
                    .background(Color.gray)
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                Button(action: { viewModel.signIn(id: id, pw: pw) }) {
                    Text("Log in")
                        .foregroundColor(Color.white)
                        .frame(minWidth: 0, maxWidth: .infinity)
                }
                    .padding()
                    .background(Color("ColorPrimary"))
                    .cornerRadius(5.0)
                NavigationLink(destination: SignupView(), isActive: $isSignUp) {
                    Button(action: { self.isSignUp = true }) { // navigation
                        Text("Sign up")
                            .foregroundColor(Color("ColorPrimary"))
                            .frame(minWidth: 0, maxWidth: .infinity)
                    }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(5.0)
                        .padding(.bottom, 20)
                }.navigationBarTitle("Log in")
                
                Divider()
                    .background(Color.gray)
                
                VStack {
                    GoogleSignInButton()
                        .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 70)
                        .onTapGesture {
                            viewModel.signInWithGoogle()
                        }
                    
                    SignInWithAppleButton(.signIn) { request in
                        let nonce = randomNonceString()
                        currentNonce = nonce
                        request.requestedScopes = [.fullName, .email]
                        request.nonce = sha256(nonce)
                    } onCompletion: { result in
                        switch result {
                            case .success(let authResults):
                                print("Authorisation successful")
                                switch authResults.credential {
                                    case let appleIDCredential as ASAuthorizationAppleIDCredential:

                                        guard let nonce = currentNonce else {
                                            fatalError("Invalid state: A login callback was received, but no login request was sent.")
                                        }
                                        guard let appleIDToken = appleIDCredential.identityToken else {
                                            fatalError("Invalid state: A login callback was received, but no login request was sent.")
                                        }
                                        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                                            print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                                            return
                                        }
                                    
                                        viewModel.signInWithApple(idTokenString: idTokenString, nonce: nonce)
                                     
                                    default:
                                      break
                                }
                            case .failure:
                                print("Authorisation failed.")
                        }
                    }
                    .signInWithAppleButtonStyle(.whiteOutline)
                    .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 70)
                }.padding()
            }
            .padding()
        }
    }
    
    //Hashing function using CryptoKit
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()

        return hashString
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
