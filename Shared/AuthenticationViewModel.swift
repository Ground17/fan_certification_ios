//
//  AuthenticationViewModel.swift
//  fancertification
//
//  Created by 유지상 on 2022/05/04.
//

import Firebase
import GoogleSignIn

class AuthenticationViewModel: ObservableObject {

    enum SignInState {
        case signedIn
        case signedOut
    }

    @Published var state: SignInState = .signedOut
    @Published var loading: Bool = false
    
    func signIn(id: String, pw: String) {
        self.loading = true
        Auth.auth().signIn(withEmail: id, password: pw) { (result, error) in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else {
                print("success")
                if ((Auth.auth().currentUser?.isEmailVerified) != nil) {
                    self.state = .signedIn
                } else {
                    Auth.auth().currentUser?.sendEmailVerification { (error) in
                        if error != nil {
                            print("email send error")
                        }
                    }
                }
            }
            self.loading = false
        }
    }
    
    func signUp(id: String, pw: String, pwConfirm: String) {
        self.loading = true
        Auth.auth().createUser(withEmail: id, password: pw) { authResult, error in
            guard error == nil else {
                self.loading = false
                return
            }
            
            switch authResult {
                case .none:
                    print("Could not create account.")
                    self.loading = false
                case .some(_):
                    print("User created")
                
                    Auth.auth().currentUser?.sendEmailVerification { (error) in
                        if error != nil {
                            print("email send error")
                        }
                    }
                    self.loading = false
            }
        }
    }
    
    func signInWithApple(idTokenString: String, nonce: String) {
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if (error != nil) {
                // Error. If error.code == .MissingOrInvalidNonce, make sure
                // you're sending the SHA256-hashed nonce as a hex string with
                // your request to Apple.
                print(error?.localizedDescription as Any)
                return
            }
            self.state = .signedIn
            print("signed in")
        }

        print("\(String(describing: Auth.auth().currentUser?.uid))")
    }
    
    func signInWithGoogle() {
      // 1
      if GIDSignIn.sharedInstance.hasPreviousSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { [unowned self] user, error in
            authenticateUser(for: user, with: error)
        }
      } else {
        // 2
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // 3
        let configuration = GIDConfiguration(clientID: clientID)
        
        // 4
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
        
        // 5
        GIDSignIn.sharedInstance.signIn(with: configuration, presenting: rootViewController) { [unowned self] user, error in
          authenticateUser(for: user, with: error)
        }
      }
    }
    
    private func authenticateUser(for user: GIDGoogleUser?, with error: Error?) {
      // 1
      if let error = error {
        print(error.localizedDescription)
        return
      }
      
      // 2
      guard let authentication = user?.authentication, let idToken = authentication.idToken else { return }
      
      let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
      
      // 3
      Auth.auth().signIn(with: credential) { [unowned self] (_, error) in
        if let error = error {
          print(error.localizedDescription)
        } else {
          self.state = .signedIn
        }
      }
    }
    
    func signOut() {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
}
