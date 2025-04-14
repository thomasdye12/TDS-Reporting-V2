//
//  ViewController.swift
//  TDS Reporting V2
//
//  Created by Thomas Dye on 13/04/2025.
//

import UIKit
import SwiftUI


let auth = Auth<login>(Config: Auth_Config(APNS:true,
                                           BundleID: "net.thomasdye.TDS-Reporting-V2",AccountType: "TDS",
                                             TokenSuiteName: "group.net.thomasdye.Auth_Creds",
                                                       RequireFaceID: true,
                                           LoginViewconfig:
                                                        LoginViewConfigops(
                                                            Title: "TDS Reporting",
                                                            Username: true, Password: true,
                                                            Canlogin: true, signinwithApple: false,
                                                            Nologin_message: "Server error",
                                                            backgroundColour:.purple,
                                                            LoginButtonColour: UIColor(red: 0.2, green: 0.7, blue: 1, alpha: 1), LoginImage_name: "TDS",
                                                            TDS_Login_explain_text: false),UNAuthorizationOptions: [.alert, .badge , .sound]))

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        auth.Request_Auth(viewController: self, comp: { loginRes in
            DispatchQueue.main.async {
                let hostingController = UIHostingController(rootView: MainView())
                self.addChild(hostingController)
                self.view.addSubview(hostingController.view)
                hostingController.view.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    hostingController.view.leadingAnchor.constraint(equalTo:  self.view.leadingAnchor),
                    hostingController.view.trailingAnchor.constraint(equalTo:  self.view.trailingAnchor),
                    hostingController.view.topAnchor.constraint(equalTo:  self.view.topAnchor),
                    hostingController.view.bottomAnchor.constraint(equalTo:  self.view.bottomAnchor)
                ])
                hostingController.didMove(toParent: self)
            }
        })
    }


}

