//
//  UserProfileViewController.swift
//  JsonApp
//
//  Created by  Pavel on 19.08.2021.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn

class UserProfileViewController: UIViewController {
    
    private var provider: String?
    private var currentUser: CurrentUser?
    
    lazy var logoutButton: UIButton = {
        let logButton = UIButton()
        logButton.frame = CGRect(x: 32, y: view.frame.height - 172,
                                 width: view.frame.width - 64, height: 50)
        logButton.backgroundColor = .darkGray
        logButton.setTitle("Log Out", for: .normal)
        logButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        logButton.setTitleColor(.white, for: .normal)
        logButton.layer.cornerRadius = 4
        logButton.addTarget(self, action: #selector(signOut), for: .touchUpInside)
        return logButton
    }()
    
    @IBOutlet weak var userNameLable: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        userNameLable.isHidden = true
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchingUserData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    private func setupViews() {
        view.addSubview(logoutButton)
    }
}

extension UserProfileViewController {
    
    private func openLoginViewController() {
        // if !AccessToken.isCurrentAccessTokenActive
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let loginViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                loginViewController.modalPresentationStyle = .fullScreen
                self.present(loginViewController, animated: true)
                return
            }
        } catch {
            print("Failed to sign out with error: ", error.localizedDescription)
        }
    }
    
    private func fetchingUserData() {
        if Auth.auth().currentUser != nil {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            Database.database().reference()
                .child("users")
                .child(uid)
                .observeSingleEvent(of: .value) { (snapshot) in
                    
                    guard let userData = snapshot.value as? [String: Any] else { return }
                    self.currentUser = CurrentUser(uid: uid, data: userData)
                    self.activityIndicator.stopAnimating()
                    self.userNameLable.isHidden = false
                    self.userNameLable.text = self.getProviderData()
                    
                } withCancel: { (error) in
                    print(error)
                }
        }
    }
    
    @objc private func signOut() {
        if let providerData = Auth.auth().currentUser?.providerData {
            for userInfo in providerData {
                switch userInfo.providerID {
                case "facebook.com":
                    LoginManager().logOut()
                    print("User did log out of Facebook")
                    openLoginViewController()
                case "google.com":
                    GIDSignIn.sharedInstance.signOut()
                    print("User did log out of Google")
                    openLoginViewController()
                default:
                    print("User is signed in with \(userInfo.providerID)")
                    openLoginViewController()
                }
            }
        }
    }
    
    // определение провайдера и установка лейбла на UserProfileVC
    private func getProviderData() -> String {
        var greetings = ""
        if let providerData = Auth.auth().currentUser?.providerData {
            for userInfo in providerData {
                switch userInfo.providerID {
                case "facebook.com":
                    provider = "Facebook"
                case "google.com":
                    provider = "Google"
                case "password":
                    provider = "Email"
                default:
                    break
                }
            }
            greetings = "\(currentUser?.name ?? "Noname") logged in with \(provider!)"
        }
        return greetings
    }
}
