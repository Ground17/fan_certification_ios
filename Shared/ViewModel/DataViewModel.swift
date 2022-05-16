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
    @Published var showCelebDeleteConfirm: Bool = false
    @Published var showCelebUpdateConfirm: Bool = false
    @Published var showCelebCountConfirm: Bool = false
    @Published var showSearchConfirm: Bool = false
    @Published var alertText: String = ""
    
    @Published var platform: String = "0"
    @Published var account: String = ""
    @Published var title: String = ""
    @Published var url: String = ""
    
    @Published var dateFormatter = DateFormatter()
    
    
    @Published var items: [Item] = []
    @Published var celeb: [Celeb] = []
    
    lazy private var functions = Functions.functions()
    private let db = Firestore.firestore()
    
    func closeAlert() {
        self.showAlert = false
    }
    
    func getYTChannel (query: String, update: Bool = false) {
        requestGet(url: "https://www.googleapis.com/youtube/v3/search?part=id,snippet&type=channel&q=\(query)&key=\(Keys.YTAPIKEY)") { (success, data) in
            if update {
                if data.count > 0 {
                    self.manageFollow(platform: "0", account: query, method: "update", title: data[0].snippet.title, url: data[0].snippet.thumbnails.default.url)
                }
            } else {
                DispatchQueue.main.async {
                    self.items = data
                }
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
//    #if DEBUG // test firebase functions in local
//            functions.useEmulator(withHost: "localhost", port: 5001)
//            let settings = Firestore.firestore().settings
//            settings.host = "localhost:8080"
//            settings.isPersistenceEnabled = false
//            settings.isSSLEnabled = false
//            Firestore.firestore().settings = settings
//    #endif
        
        guard Auth.auth().currentUser != nil else {
            print("We can't find current user signed in.")
            return
        }
        
        self.loading = true
        let docRef = db.collection("Users").document(Auth.auth().currentUser!.uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                guard (document["celeb"] as? [[String : Any]]) != nil else { return }
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                DispatchQueue.main.async {
                    self.celeb = (document["celeb"] as! [[String: Any]]).compactMap { data -> Celeb? in
                        return Celeb(dictionary: data)
                    }
                }
                self.loading = false
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
                
                self.loading = false
            }
        }
    }
    
    func initFormatter() {
        self.dateFormatter.dateStyle = .short
        self.dateFormatter.timeStyle = .medium
    }
    
    func calDates(since: Date) -> Int {
        let calendar = Calendar.current

        // Replace the hour (time) of both dates with 00:00
        let date = calendar.startOfDay(for: since)
        let now = Date()
        
        let components = calendar.dateComponents([.day], from: date, to: now)
        
        return components.day ?? 0
    }
    
    func alert(message: String) {
        self.showAlert = true
        self.alertText = message
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
          if let data = result?.data as? [String: Any], let status = data["status"] as? Int {
              if status == 200 { // success
                  for i in self.celeb.indices {
                      if self.celeb[i].platform == platform && self.celeb[i].account == account {
                          self.alert(message: "Successfully updated.")
                          DispatchQueue.main.async {
                              self.celeb[i].count += 1
                              self.celeb[i].recent = Date()
                          }
                          break
                      }
                  }
              } else {
                  if let message = data["message"] as? String {
                      print(message)
                      self.alert(message: message)
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
                  if method == "add" {
                      self.alert(message: "Successfully added.")
                      DispatchQueue.main.async {
                          self.celeb.append(Celeb(dictionary: ["account": account, "platform": platform, "count": 0, "recent": Date(), "since": Date(), "title": title, "url": url]))
                      }
                  } else if method == "update" {
                      for i in self.celeb.indices {
                          if self.celeb[i].platform == platform && self.celeb[i].account == account {
                              self.alert(message: "Successfully updated.")
                              DispatchQueue.main.async {
                                  self.celeb[i].title = title ?? ""
                                  self.celeb[i].url = url ?? ""
                              }
                              break
                          }
                      }
                  } else if method == "delete" {
                      self.alert(message: "Successfully deleted.")
                      DispatchQueue.main.async {
                          self.celeb = self.celeb.filter( { (value: Celeb) -> Bool in return (value.platform != platform || value.account != account) } )
                      }
                  } else {
                      self.alert(message: "Method error is occured...")
                  }
              } else {
                  if let message = data["message"] as? String {
                      print(message)
                      self.alert(message: message)
                  }
              }
          }
        }
    }
}
