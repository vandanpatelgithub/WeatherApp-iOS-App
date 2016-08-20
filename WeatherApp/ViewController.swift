
import UIKit
import MapKit


class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    var city: City!
    var _locality: String!
    var _latitude: Double!
    var _longitude: Double!
    var _state: String!
    var _county: String!
    var _country: String!
    
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
    
    func readCityJSON() {
        if let path  = NSBundle.mainBundle().pathForResource("city", ofType: "json") {
            if let jsonData = NSData(contentsOfFile: path) {
                do {
                    if let jsonResult: [Dictionary<String, AnyObject>] =  try ((NSJSONSerialization.JSONObjectWithData(jsonData , options: .MutableContainers) as? [Dictionary<String, AnyObject>])) {
                        let filteredResult = jsonResult.filter({
                            let latitude_difference = $0["coord"]!["lat"] as! Double - self._latitude
                            let longitude_difference = $0["coord"]!["lon"] as! Double - self._longitude
                            let cityName = $0["name"] as! String
                            return cityName == self._locality && latitude_difference < 0.1 && longitude_difference < 0.1
                        })
                        if let id = filteredResult[0]["_id"] {
                            self.city = City(cityID: "\(id)")
                            setProperties(self.city)
                            self.city.downloadDetails ({
                                print("WE GOT HERE!")
                            })
                        }
                    }
                } catch let error as NSError {
                    print(error.debugDescription)
                }
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        let location = locations.last
        CLGeocoder().reverseGeocodeLocation(location!) { (placemarks: [CLPlacemark]?, error: NSError?) in
            if (error != nil) {
                print("Reverse Geocoder Failed With Error : \(error!.localizedDescription)")
                return
            }
            if let pm = placemarks where placemarks?.count > 0 {
                let placemark = pm[0]
                self.displayLocationInfo(placemark, completed: {
                    self.readCityJSON()
                })
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
    
    func setProperties(city: City) {
        city.cityName = self._locality
        city.cityState = self._state
        city.cityCounty = self._county
        city.cityCountry = self._country
    }
    
    func displayLocationInfo(placemark: CLPlacemark, completed: LocationUpdateComplete) {
        if let locality = placemark.locality {
            self._locality = locality
        }
        
        if let adminArea = placemark.administrativeArea {
            self._state = adminArea
        }
        
        if let subAdminArea = placemark.subAdministrativeArea {
            self._county = subAdminArea
        }
        
        if let country = placemark.country {
            self._country = country
        }
        
        if let location = placemark.location {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            self._latitude = latitude
            self._longitude = longitude
        }
        completed()
    }
}


