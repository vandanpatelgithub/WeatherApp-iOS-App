import Foundation

class City {
    private var _cityID: String!
    private var _cityName: String!
    private var _cityCountry: String!
    private var _cloudiness: String!
    private var _description: String!
    private var _sunrise: String!
    private var _sunset: String!
    private var _humidity: String!
    private var _windSpeed : String!
    private var _mainTemp: String!
    private var _minTemp: String!
    private var _maxTemp: String!
    
    init(cityID: String) {
        self._cityID = cityID
    }
    
    var cityName: String {
        if _cityName == nil {
            _cityName = ""
        }
        return _cityName
    }
    
    var cityCountry: String {
        if _cityCountry == nil {
            _cityCountry = ""
        }
        return _cityCountry
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
}
