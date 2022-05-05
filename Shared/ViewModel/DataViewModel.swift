//
//  DataViewModel.swift
//  fancertification
//
//  Created by 유지상 on 2022/05/05.
//

import Firebase

class DataViewModel: ObservableObject {
    @Published var loading: Bool = false
    
    @Published var showAlert: Bool = false
    @Published var alertText: String = ""
    
    @Published var items: [Item] = []
    @Published var celeb: [Celeb] = []
    
    lazy private var functions = Functions.functions()
    private let db = Firestore.firestore()
    
    func closeAlert() {
        self.showAlert = false
    }
    
    func getYTChannel (query: String) {
        requestGet(url: "https://www.googleapis.com/youtube/v3/search?part=id,snippet&type=channel&q=\(query)&key=\(Keys.YTAPIKEY)") { (success, data) in
            print(data)
            self.items = data
        }
    }
    
    private func requestGet(url: String, completionHandler: @escaping (Bool, [Item]) -> Void) {
        guard let url = URL(string: url) else {
            print("Error: cannot create URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("Error: error calling GET")
                print(error!)
                return
            }
            guard let data = data else {
                print("Error: Did not receive data")
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode else {
                print("Error: HTTP request failed")
                return
            }
            guard let output = try? JSONDecoder().decode(Response.self, from: data) else {
                print("Error: JSON Data Parsing failed")
                return
            }
            
            completionHandler(true, output.items)
        }.resume()
    }
    
    func getCeleb() {
        let docRef = db.collection("Users").document(Auth.auth().currentUser!.uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                guard (document["celeb"] as? [[String : Any]]) != nil else { return }
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                
                self.celeb = document["celeb"] as! [Celeb]
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func addHeart(platform: String, account: String) {
        functions.httpsCallable("addHeart").call(["platform": platform, "account": account]) { result, error in
          if let error = error as NSError? {
            if error.domain == FunctionsErrorDomain {
              let code = FunctionsErrorCode(rawValue: error.code)
              let message = error.localizedDescription
              let details = error.userInfo[FunctionsErrorDetailsKey]
            }
            // ...
          }
          if let data = result?.data as? [String: Any], let status = data[""] as? Int {
              if status == 200 { // success
                  self.getCeleb()
              } else {
                  if let message = data["message"] as? String {
                      print(message)
                  }
              }
          }
        }
    }
    
    func manageFollow(platform: String, account: String, method: String = "add", url: String?) {
        functions.httpsCallable("manageFollow").call(["platform": platform, "account": account, "method": method]) { result, error in
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
                  self.getCeleb()
              } else {
                  if let message = data["message"] as? String {
                      print(message)
                  }
              }
          }
        }
    }
}
