
import Foundation

typealias LocationUpdateComplete = () -> ()

typealias DownloadComplete = () -> ()

let BASE_URL = "http://api.openweathermap.org/data/2.5/weather?id="

let API_KEY = "&APPID=d053c23aedffdae96d997e3d7a685b18"

let UNITS = "&units=imperial"