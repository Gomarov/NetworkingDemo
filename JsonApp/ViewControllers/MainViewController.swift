//
//  MainViewController.swift
//  JsonApp
//
//  Created by  Pavel on 06.02.2021.
//

import UIKit
import UserNotifications
import FBSDKLoginKit
import FirebaseAuth

private let reuseIdentifier = "Cell"

enum UserActions: String, CaseIterable {
    case downloadImage = "Download Image"
    //case exampleOne = "Example One"
    //case exampleTwo = "Example Two"
    //case exampleThree = "Example Three"
    //case exampleFour = "Example Four"
    case ourCourses = "Our Courses"
    case postRequest = "Post Request"
    case ourCoursesAlamofire = "Our Courses Alamofire"
    case postAlamofire = "Post with Alamofire"
    case downloadFile = "Download File"
}

class MainViewController: UICollectionViewController {
    
    private let userActions = UserActions.allCases
    private var alert: UIAlertController!
    private var dataProvider = DataProvider()
    private var filePath: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerForNotification()
        
        dataProvider.fileLocation = { (location) in
            // сохранить файл для дальнейшего использовнаия
            print("Download finished: \(location.absoluteString)")
            self.filePath = location.absoluteString
            self.dismiss(animated: false, completion: nil)
            self.postNotification()
        }
        checkLoggedIn()
    }
    
    private func showAlert() {
        
        alert = UIAlertController(title: "Downloading", message: "0%", preferredStyle: .alert)
        let height = NSLayoutConstraint(item: alert.view!,
                                        attribute: .height,
                                        relatedBy: .equal,
                                        toItem: nil,
                                        attribute: .notAnAttribute,
                                        multiplier: 0,
                                        constant: 170)
        alert.view.addConstraint(height)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (_) in
            self.dataProvider.stopDownload()
        }
        alert.addAction(cancelAction)
        present(alert, animated: true) {
            
            let size = CGSize(width: 40, height: 40)
            let point = CGPoint(x: self.alert.view.frame.width / 2 - size.width / 2,
                                y: self.alert.view.frame.height / 2 - size.height / 2)
            let activityIndicator = UIActivityIndicatorView(frame: CGRect(origin: point, size: size))
            activityIndicator.color = .gray
            activityIndicator.startAnimating()
            
            let progressView = UIProgressView(frame: CGRect(x: 0,
                                                            y: self.alert.view.frame.height - 44,
                                                            width: self.alert.view.frame.width,
                                                            height: 2))
            progressView.tintColor = .blue
            
            self.dataProvider.onProgress = { (progress) in
                progressView.progress = Float(progress)
                self.alert.message = String(Int(progress*100)) + "%"
            }
            self.alert.view.addSubview(activityIndicator)
            self.alert.view.addSubview(progressView)
        }
    }
    
    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userActions.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UserActionCell
        
        cell.userActionLabel.text = userActions[indexPath.item].rawValue
        
        return cell
    }
    
    // MARK: - UICollectionViewDeligate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let userAction = userActions[indexPath.item]
        
        switch userAction {
        case .downloadImage:
            performSegue(withIdentifier: "ShowImage", sender: self)
        //case .exampleOne: performSegue(withIdentifier: "ExampleOne", sender: self)
        //case .exampleTwo: performSegue(withIdentifier: "ExampleTwo", sender: self)
        //case .exampleThree: performSegue(withIdentifier: "ExampleThree", sender: self)
        //case .exampleFour: performSegue(withIdentifier: "ExampleFour", sender: self)
        case .ourCourses:
            performSegue(withIdentifier: "OurCourses", sender: self)
        case .postRequest:
            postRequest()
        case .ourCoursesAlamofire:
            performSegue(withIdentifier: "OurCoursesAlamofire", sender: self)
        case .postAlamofire:
            performSegue(withIdentifier: "PostAlamofire", sender: self)
        case .downloadFile:
            showAlert()
            dataProvider.startDownload()
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier != "ShowImage" {
            let coursesVC = segue.destination as! CoursesViewController
            switch segue.identifier {
            //case "ExampleOne": coursesVC.fetchDataV1()
            //case "ExampleTwo": coursesVC.fetchDataV2()
            //case "ExampleThree": coursesVC.fetchDataV3()
            //case "ExampleFour": coursesVC.fetchDataV4()
            case "OurCourses":
                coursesVC.fetchData()
            case "OurCoursesAlamofire":
                coursesVC.fetchDataWithAlamofire()
            case "PostAlamofire":
                coursesVC.postWithAlamofire()
            default: break
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MainViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width - 48, height: 100)
    }
}

extension MainViewController {
    
    private func postRequest() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else { return }
        
        let userData = [
            "course": "Networking",
            "lesson": "GET and POST"
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: userData, options: []) else { return }
        
        request.httpBody = httpBody
        
        URLSession.shared.dataTask(with: request) { (data, response, _) in
            guard let response = response, let data = data else { return }
            print(response)
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print(json)
            } catch let error {
                print(error)
            }
        }.resume()
    }
}

extension MainViewController {
    
    private func registerForNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (_, _) in
        }
    }
    
    private func postNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Dowmload complete!"
        content.body = "File path: \(filePath!)"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        
        let request = UNNotificationRequest(identifier: "TransferComplete", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}

// MARK: Facebook SDK
extension MainViewController {
    private func checkLoggedIn() {
        
        if Auth.auth().currentUser == nil {
            // if !AccessToken.isCurrentAccessTokenActive
            DispatchQueue.main.async {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let loginViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                loginViewController.modalPresentationStyle = .fullScreen
                self.present(loginViewController, animated: true)
                return
            }
        }
    }
}
