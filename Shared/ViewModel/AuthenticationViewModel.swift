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
    
    enum SignUpState {
        case signedUp
        case none
    }

    @Published var state: SignInState = .signedOut
    @Published var loading: Bool = false
    
    @Published var signUp: SignUpState = .none
    @Published var showAlert: Bool = false
    @Published var alertText: String = ""
    @Published var checkDeleteAccount: Bool = false
    
    func closeAlert() {
        self.showAlert = false
    }
    
    func signIn(id: String, pw: String) {
        self.loading = true
        guard id != "" && pw != "" else {
            self.showAlert = true
            self.alertText = "Fill in the blank(s)."
            self.loading = false
            return
        }
        
        Auth.auth().signIn(withEmail: id, password: pw) { (result, error) in
            if error != nil {
                print(error?.localizedDescription ?? "")
                self.showAlert = true
                self.alertText = error?.localizedDescription ?? ""
            } else {
                print("success")
                if (Auth.auth().currentUser != nil && Auth.auth().currentUser!.isEmailVerified) {
                    self.state = .signedIn
                } else {
                    self.showAlert = true
                    self.alertText = "A confirmation email has been sent to verify that this is a valid email. Please check your mailbox. If you haven't received an email, please try again in a few minutes."
                    
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
        
        guard id != "" && pw != "" && pwConfirm != "" else {
            self.showAlert = true
            self.alertText = "Fill in the blank(s)."
            self.loading = false
            return
        }
        
        guard pw == pwConfirm else {
            self.showAlert = true
            self.alertText = "Please check if the password and password confirmation are the same."
            self.loading = false
            return
        }
        
        Auth.auth().createUser(withEmail: id, password: pw) { authResult, error in
            guard error == nil else {
                self.loading = false
                self.showAlert = true
                self.alertText = error?.localizedDescription ?? ""
                return
            }
            
            switch authResult {
                case .none:
                    print("Could not create account.")
                    self.showAlert = true
                    self.alertText = "Could not create account."
                    self.loading = false
                case .some(_):
                    print("User created")
                    self.showAlert = true
                    self.alertText = "A confirmation email has been sent to verify that this is a valid email. Please check your mailbox."
                    self.signUp = .signedUp
                
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
                self.showAlert = true
                self.alertText = error?.localizedDescription ?? "Log in Error"
                return
            }
            self.state = .signedIn
            print("signed in")
        }

        print("\(String(describing: Auth.auth().currentUser?.uid))")
    }
    
    func signInWithGoogle() {
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { [unowned self] user, error in
                authenticateUser(for: user, with: error)
            }
        } else {
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }

            let configuration = GIDConfiguration(clientID: clientID)

            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            guard let rootViewController = windowScene.windows.first?.rootViewController else { return }

            GIDSignIn.sharedInstance.signIn(with: configuration, presenting: rootViewController) { [unowned self] user, error in
              authenticateUser(for: user, with: error)
            }
        }
    }
    
    private func authenticateUser(for user: GIDGoogleUser?, with error: Error?) {
      if let error = error {
          print(error.localizedDescription)
          self.showAlert = true
          self.alertText = error.localizedDescription
          return
      }
      
      guard let authentication = user?.authentication, let idToken = authentication.idToken else { return }
      
      let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
      
      Auth.auth().signIn(with: credential) { [unowned self] (_, error) in
        if let error = error {
            print(error.localizedDescription)
            self.showAlert = true
            self.alertText = error.localizedDescription
        } else {
            self.state = .signedIn
        }
      }
    }
    
    func signOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            self.state = .signedOut
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    func deleteAccount() {
        Functions.functions().httpsCallable("deleteAccount").call() { result, error in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    let code = FunctionsErrorCode(rawValue: error.code)
                    let message = error.localizedDescription
                    let details = error.userInfo[FunctionsErrorDetailsKey]
                }
                // ...
            }
            
            if let data = result?.data as? [String: Any], let status = data["status"] as? Int {
                if status == 200 { // success
                    print("Deletion success!")
                    
                    let firebaseAuth = Auth.auth()
                    firebaseAuth.currentUser?.delete { (error) in
                        if let error = error {
                            print(error.localizedDescription)
                            self.showAlert = true
                            self.alertText = error.localizedDescription
                            self.signOut()
                        } else { // maybe success...
                            self.showAlert = true
                            self.alertText = "Deletion success!"
                            print("Deletion success!")
                            self.state = .signedOut
                        }
                    }
                } else {
                    if let message = data["message"] as? String {
                        self.showAlert = true
                        self.alertText = message
                        print(message)
                    }
                }
            }
        }
    }
    
    func checkSignIn() {
        if (Auth.auth().currentUser != nil && Auth.auth().currentUser!.isEmailVerified) {
            self.state = .signedIn
        } else {
            self.state = .signedOut
        }
    }
}
