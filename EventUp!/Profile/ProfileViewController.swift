//
//  ProfileViewController.swift
//  EventUp!
//
//  Created by Siraj Zaneer on 10/18/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import SVProgressHUD
import Firebase

class ProfileViewController: UIViewController {
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    var user: EventUser!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setup()
    }
    
    func setup() {
        view.isUserInteractionEnabled = false
        SVProgressHUD.show()
        
        guard let user = Auth.auth().currentUser else {
            return
        }
        EventUpClient.sharedInstance.getUserInfo(user: user, success: { (user) in
            DispatchQueue.main.async {
                self.user = user
                self.nameLabel.text = user.name
                self.ratingLabel.text = "\(user.rating)"
                
                if let image = user.image {
                    self.userImageView.image = EventUpClient.sharedInstance.base64DecodeImage(image)
                }
                self.setupEvents()
                
            }
        }) { (error) in
            self.view.isUserInteractionEnabled = true
            SVProgressHUD.dismiss()
        }
    }

    func setupEvents() {
        EventUpClient.sharedInstance.getEvents(success: { (events) in
            for event in events {
                print(event.rating)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
