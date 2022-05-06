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
    @Published var showCelebConfirm: Bool = false
    @Published var showSearchConfirm: Bool = false
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
            DispatchQueue.main.async {
                self.items = data
            }
        }
    }
    
    private func transformURLString(_ string: String) -> URLComponents? {
        guard let urlPath = string.components(separatedBy: "?").first else {
            return nil
        }
        var components = URLComponents(string: urlPath)
        if let queryString = string.components(separatedBy: "?").last {
            components?.queryItems = []
            let queryItems = queryString.components(separatedBy: "&")
            for queryItem in queryItems {
                guard let itemName = queryItem.components(separatedBy: "=").first,
                      let itemValue = queryItem.components(separatedBy: "=").last else {
                        continue
                }
                components?.queryItems?.append(URLQueryItem(name: itemName, value: itemValue))
            }
        }
        return components!
    }
    
    private func requestGet(url: String, completionHandler: @escaping (Bool, [Item]) -> Void) {
        let components = transformURLString(url)

        guard let url = components?.url else {
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
                
                DispatchQueue.main.async {
                    self.celeb = document["celeb"] as! [Celeb]
                }
            } else {
                print("Document does not exist")
                let docData: [String: Any] = [
                    "celeb": []
                ]
                
                docRef.setData(docData) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                }
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
    
    func manageFollow(platform: String, account: String, method: String = "add", title: String?, url: String?) {
        functions.httpsCallable("manageFollow").call(["platform": platform, "account": account, "method": method, "title": title, "url": url]) { result, error in
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
                  self.showAlert = true
                  self.alertText = "Successfully added."
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
