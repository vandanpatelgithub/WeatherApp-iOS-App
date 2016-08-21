import Foundation
import Alamofire

class City {
    private var _cityID: String!
    private var _cityName: String!
    private var _cityCountry: String!
    private var _cityState: String!
    private var _cityCounty: String!
    private var _cloudiness: String!
    private var _description: String!
    private var _sunrise: String!
    private var _sunset: String!
    private var _humidity: String!
    private var _windSpeed : String!
    private var _mainTemp: String!
    private var _minTemp: String!
    private var _maxTemp: String!
    private var _cityURL: String!
    private var _weatherIcon: String!
    private var _timeZone: String!
    private var _lastUpdatedTime: String!
    private var _lastUpdateDate: String!
    
    private var timeFormatter = NSDateFormatter()
    
    init(cityID: String) {
        self._cityID = cityID
        self._cityURL = "\(BASE_URL)\(self._cityID)\(API_KEY)\(UNITS)"
    }
    
    var cityName: String {
        
        get {
            if _cityName == nil {
                _cityName = ""
            }
            return _cityName
        }
        
        set {
            if newValue != "" {
                _cityName = newValue
            }
        }
    }
    
    var cityCountry: String {
        
        get {
            if _cityCountry == nil {
                _cityCountry = ""
            }
            return _cityCountry
        }
        
        set {
            if newValue != "" {
                _cityCountry = newValue
            }
        }
    }
    
    var cityCounty: String {
        
        get {
            if _cityCounty == nil {
                _cityCounty = ""
            }
            return _cityCounty
        }
        set {
            if newValue != "" {
                _cityCounty = newValue
            }
        }
    }
    
    var cityState: String {
        
        get {
            if _cityState == nil {
                _cityState = ""
            }
            return _cityState
        }
        set {
            if newValue != "" {
                _cityState = newValue
            }
        }
    }
    
    var cloudiness: String {
        if _cloudiness == nil {
            _cloudiness = ""
        }
        return _cloudiness
    }
    
    var description: String {
        if _description == nil {
            _description = ""
        }
        return _description
    }
    
    var sunrise: String {
        if _sunrise == nil {
            _sunrise = ""
        }
        return _sunrise
    }
    
    var sunset: String {
        if _sunset == nil {
            _sunset = ""
        }
        return _sunset
    }
    
    var humidity: String {
        if _humidity == nil {
            _humidity = ""
        }
        return _humidity
    }
    
    var windSpeed: String {
        if _windSpeed == nil {
            _windSpeed = ""
        }
        return _windSpeed
    }
    
    var mainTemp: String {
        if _mainTemp == nil {
            _mainTemp = ""
        }
        return _mainTemp
    }
    
    var minTemp: String {
        if _minTemp == nil {
            _minTemp = ""
        }
        return _minTemp
    }
    
    var maxTemp: String {
        if _maxTemp == nil {
            _maxTemp = ""
        }
        return _maxTemp
    }
    
    var cityURL: String {
        if _cityURL == nil {
            _cityURL = ""
        }
        return _cityURL
    }
    
    var weatherIcon: String {
        if _weatherIcon == nil {
            _weatherIcon = ""
        }
        return _weatherIcon
    }
    
    var timeZone: String {
        get {
            if _timeZone == nil {
                _timeZone = ""
            }
            return _timeZone
        }
        set {
            if newValue != "" {
                _timeZone = newValue
            }
        }
    }
    
    var lastUpdatedTime: String {
        if _lastUpdatedTime == nil {
            _lastUpdatedTime = ""
        }
        return _lastUpdatedTime
    }
    
    var lastUpdateDate: String {
        if _lastUpdateDate == nil {
            _lastUpdateDate = ""
        }
        return _lastUpdateDate
    }
    
    func fromUnixToLocalTime(date : NSDate) -> String {
        self.setTimeZone()
        timeFormatter.timeStyle = .ShortStyle
        return self.timeFormatter.stringFromDate(date)
    }
    
    func fromUnixToLocalDate(date: NSDate) -> String {
        timeFormatter = NSDateFormatter()
        self.setTimeZone()
        timeFormatter.dateStyle = .MediumStyle
        return self.timeFormatter.stringFromDate(date)
    }
    
    func setTimeZone() {
        timeFormatter.timeZone = NSTimeZone(abbreviation: self.timeZone)
    }
    
    func downloadDetails(completed: DownloadComplete) {
        let url = NSURL(string: self._cityURL)!
        Alamofire.request(.GET, url).validate().responseJSON { (response: Response<AnyObject, NSError>) in
            switch response.result {
            
            case .Success(let data):
                
                if let dict = data as? Dictionary<String, AnyObject> {
                    if let mainTemp = dict["main"]!["temp"] as? Int {
                        self._mainTemp = "\(mainTemp)"
                    }
                    
                    if let cloudiness = dict["clouds"]!["all"] as? Int {
                        self._cloudiness = "\(cloudiness)"
                    }
                    
                    if let description = dict["weather"]![0]["description"] as? String {
                        self._description = description
                    }
                    
                    if let sunrise = dict["sys"]!["sunrise"] as? Double {
                        let date = NSDate(timeIntervalSince1970: sunrise)
                        self._sunrise = self.fromUnixToLocalTime(date)
                    }
                    
                    if let sunset = dict["sys"]!["sunset"] as? Double {
                        let date = NSDate(timeIntervalSince1970: sunset)
                        self._sunset = self.fromUnixToLocalTime(date)
                    }
                    
                    if let lastUpdated = dict["dt"] as? Double {
                        let date = NSDate(timeIntervalSince1970: lastUpdated)
                        self._lastUpdatedTime = self.fromUnixToLocalTime(date)
                        self._lastUpdateDate = self.fromUnixToLocalDate(date)
                        print("Last Updated Time : \(self._lastUpdatedTime)")
                        print("Last Updated Date : \(self._lastUpdateDate)")
                    }
                    
                    if let humidity = dict["main"]!["humidity"] as? Int {
                        self._humidity = "\(humidity)"
                    }
                    
                    if let windSpeed = dict["wind"]!["speed"] as? Double {
                        self._windSpeed = "\(windSpeed)"
                    }
                    
                    if let minTemp = dict["main"]!["temp_min"] as? Int {
                        self._minTemp = "\(minTemp)"
                    }
                    
                    if let maxTemp = dict["main"]!["temp_max"] as? Int {
                        self._maxTemp = "\(maxTemp)"
                    }
                    
                    if let icon = dict["weather"]![0]["icon"] as? String {
                        self._weatherIcon = icon
                    }
                }
                completed()
            
            case .Failure(let error):
                print("Alamofire Request Failed with Error : \(error.debugDescription)")
                
            }
        }
    }
}
