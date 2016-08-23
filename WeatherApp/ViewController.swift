
import UIKit
import MapKit


class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var filteredArray = [Dictionary<String, AnyObject>]()
    
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
            do {
                let data = try String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
                let lines = data.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
                
                for line in lines {
                    if let dataForJSON = line.dataUsingEncoding(NSUTF8StringEncoding) {
                        if let jsonData: Dictionary<String, AnyObject> = try NSJSONSerialization.JSONObjectWithData(dataForJSON, options: .MutableContainers) as? Dictionary<String, AnyObject> {
                            
                            let cityName = jsonData["name"] as! String
                            if cityName == self._locality {
                                filteredArray.append(jsonData)
                            }
                        }
                    }
                }
            }
            catch let error as NSError {
                print(error.debugDescription)
            }
        }
        
        if filteredArray.count == 1 {
            let id = filteredArray[0]["_id"] as! Int
            createAndPrepareCityObject(id)
        }
            
        else if filteredArray.count > 1 {
            let index = filteredArray.count - 1
            
            for x in 0...index {
                let latitude_difference = abs(filteredArray[x]["coord"]!["lat"] as! Double - self._latitude)
                let longitude_difference = abs(filteredArray[x]["coord"]!["lon"] as! Double - self._longitude)
                
                if latitude_difference < 0.01 && longitude_difference < 0.01 {
                    let id = filteredArray[x]["_id"] as! Int
                    createAndPrepareCityObject(id)
                    break
                }
            }
        }
            
        else {
            print("Your City Doesn't Exist!")
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
        
        if let image = UIImage(named: self.city.weatherIcon) {
            self.weatherImage.image = image
        }
        
        
    }
    
    func createAndPrepareCityObject(id: Int) {
        self.city = City(cityID: "\(id)")
        setProperties(self.city)
        self.city.downloadDetails ({
            self.updateUI()
        })
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


