
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
    var _timeZone: String!
    
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var countyStateLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    
    @IBOutlet weak var updatedTimeLabel: UILabel!
    @IBOutlet weak var mainTempLabel: UILabel!
    @IBOutlet weak var weatherDesc: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var cloudsLabel: UILabel!
    
    @IBOutlet weak var latLongLabel: UILabel!
    @IBOutlet weak var windSpeed: UILabel!
    @IBOutlet weak var didYouKnow: UITextView!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.didYouKnow.setContentOffset(CGPointZero, animated: true)
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.checkAuthorizationStatus()
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.didYouKnow.setContentOffset(CGPointZero, animated: false)
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
                                self.updateUI()
                            })
                        } else {
                            print("Your City Doesn't Exist. Sorry :)")
                        }
                    }
                } catch let error as NSError {
                    print(error.debugDescription)
                }
            }
        }
    }
    
    func updateUI() {
        
        self.dateLabel.text = self.city.lastUpdateDate
        self.cityNameLabel.text = self.city.cityName.uppercaseString
        self.countyStateLabel.text = "\(self.city.cityCounty), \(self.city.cityState)"
        self.minTempLabel.text = "\(self.city.minTemp)°F"
        self.maxTempLabel.text = "\(self.city.maxTemp)°F"
        self.updatedTimeLabel.text = "Updated: \(self.city.lastUpdatedTime)"
        self.mainTempLabel.text = "\(self.city.mainTemp)°F"
        self.weatherDesc.text = self.city.description.capitalizedString
        self.sunriseLabel.text = self.city.sunrise
        self.sunsetLabel.text = self.city.sunset
        self.humidityLabel.text = "\(self.city.humidity)%"
        self.cloudsLabel.text = "\(self.city.cloudiness)%"
        self.windSpeed.text = "\(self.city.windSpeed)"
        self.latLongLabel.text = "\(self.city.latitude)/\(self.city.longitude)"
        
        let randomIndex = Int(arc4random_uniform(UInt32(CALIFORNIA.count)))
        self.didYouKnow.text = CALIFORNIA[randomIndex]
        
        
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
        city.timeZone = self._timeZone
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
        
        if let timezone = placemark.timeZone {
            self._timeZone = timezone.abbreviation
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


