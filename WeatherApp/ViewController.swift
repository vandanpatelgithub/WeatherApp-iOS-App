
import UIKit
import MapKit


class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.locationManager.delegate = self
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        self.checkAuthorizationStatus()
        
        if CLLocationManager.locationServicesEnabled() {
            
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(manager.location!) { (placemarks: [CLPlacemark]?, error: NSError?) in
            if (error != nil) {
                print("Reverse Geocoder Failed With Error : \(error!.localizedDescription)")
                return
            }
            
            if placemarks?.count > 0{
                let pm = placemarks![0]
                self.displayLocationInfo(pm)
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error While Updating Location : \(error.localizedDescription)")
    }
    
    func checkAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() != .AuthorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func displayLocationInfo(placemark: CLPlacemark) {
        locationManager.stopUpdatingLocation()
        if let locality = placemark.locality {
            print(locality)
        }
        
        if let postalCode = placemark.postalCode {
            print(postalCode)
        }
        
        if let adminArea = placemark.administrativeArea {
            print(adminArea)
        }
        
        if let country = placemark.country {
            print(country)
        }
    }
}


