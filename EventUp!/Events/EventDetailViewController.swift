
//
//  EventDetailViewController.swift
//  EventUp!
//
//  Created by Siraj Zaneer on 9/27/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class EventDetailViewController: UIViewController, FilterDelegate {
    @IBOutlet weak var eventView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var attendeesLabel: UILabel!
    @IBOutlet weak var eventMapView: MKMapView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var rsvpButton: UIButton!
    @IBOutlet weak var userRatingLabel: UILabel!
    var event: Event!
    var eventImage: UIImage?
    var delegate: FilterDelegate!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage(named: "background")!
        let backgroundView = UIImageView(image: image)
        view.addSubview(backgroundView)
        view.sendSubview(toBack: backgroundView)
        if (UserDefaults.standard.object(forKey: "notifyUID") != nil) {
            setupFromNotify()
        } else {
            if (Auth.auth().currentUser!.uid == event.owner) {
                self.editButton.isHidden = false
            }
            setup()
        }
    }
    
    func setupFromNotify() {
        EventUpClient.sharedInstance.getEvent(uid: UserDefaults.standard.object(forKey: "notifyUID") as! String, success: { (event) in
            self.event = event
            UserDefaults.standard.removeObject(forKey: "notifyUID")
            if (Auth.auth().currentUser!.uid == event.owner) {
                self.editButton.isHidden = false
            }
            self.setup()
        }, failure: { (error) in
            print(error.localizedDescription)
        })
    }
    func setup() {
        if let eventImage = eventImage {
            eventView.image = eventImage
        } else {
            EventUpClient.sharedInstance.getEventImage(uid: event.uid, success: { (image) in
                self.eventView.image = image
            }, failure: { (error) in
                print(error)
            })
        }
        EventUpClient.sharedInstance.getUserInfo(uid: event.owner, success: { (user) in
            self.userRatingLabel.text = String(format: "%.2f", user.rating)
        }) { (error) in
            print(error.localizedDescription)
        }
        ratingLabel.text = String(format: "%.2f", event.rating)
        nameLabel.text = event.name
        descriptionLabel.text = event.info
        descriptionLabel.sizeToFit()
        let date = Date(timeIntervalSinceReferenceDate: event.date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateLabel.text = dateFormatter.string(from: date)
        //locationLabel.text = event.location
        //tagsLabel.text = event.tags
        //        if let image = event.image {
        //            eventView.image = EventUpClient.sharedInstance.base64DecodeImage(image)
        //        }
        // Display the number of people that RSVP'd to the event
        attendeesLabel.text = "Attendees: \(event.rsvpCount!)"
        eventMapView.removeAnnotations(eventMapView.annotations)
        eventMapView.addAnnotation(eventMapView.userLocation)
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude)
        annotation.title = event.name
        let region = MKCoordinateRegion(center: annotation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        eventMapView.removeAnnotations(eventMapView.annotations)
        eventMapView.setRegion(region, animated: true)
        eventMapView.addAnnotation(annotation)
    }
    
    @IBAction func deleteEvent(_ sender: Any) {
        let alert = UIAlertController(title: "Delete " + event.name, message: "Are you sure you want to delete this event?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) in
            EventUpClient.sharedInstance.deleteEvent(event: self.event, success: { 
                self.onSuccessful()
            }) { (error) in
                print(error)
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    func onSuccessful() {
        self.delegate.refresh(event: nil)
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func onNotify(_ sender: Any) {
        let alertController = UIAlertController(title: "Notify User", message: "Enter in email address of user to notify.", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addTextField { (textField : UITextField) -> Void in
            textField.placeholder = "email"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
        }
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            EventUpClient.sharedInstance.notifyUser(email: alertController.textFields![0].text!, event: self.event, success: { (user) in
                print("yay")
            }, failure: { (error) in
                print(error.localizedDescription)
            })
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func rsvpUser(_ sender: Any) {
        EventUpClient.sharedInstance.rsvpEvent(event: event, uid: Auth.auth().currentUser!.uid, success: {
            
            self.event.rsvpCount = self.event.rsvpCount + 1
            self.setup()
            let alert = UIAlertController(title: "Success!", message: "You RSVP'd to the event", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) in self.onSuccessful()}))
            self.present(alert, animated: true, completion: nil)
            
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    @IBAction func onCancelRSVP(_ sender: Any) {
    }
    func filter(type: String, order: Bool) {
        return
    }
    
    func refresh(event: Event?) {
        if let event = event {
            self.event = event
            setup()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        
        guard let segueID = segue.identifier else {
            return
        }
        
        switch segueID {
        case "editSegue":
            let destination = segue.destination as! EventCreateViewController
            destination.editEvent = event
            destination.delegate = self
        case "ratingSegue":
            let destination = segue.destination as! RatingViewController
            destination.event = event
            destination.delegate = self
        case "chatSegue":
            let destination = segue.destination as! EventChatViewController
            destination.event = self.event
            
        default:
            return
        }
    }
    
    
}
