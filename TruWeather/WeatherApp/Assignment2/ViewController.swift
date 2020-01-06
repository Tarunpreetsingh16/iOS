//
//  ViewController.swift
//  Assignment2?
//
//  Created by Student on 2019-12-07.
//  Copyright © 2019 Student. All rights reserved.
//

import UIKit
import CoreLocation

struct WeatherData :Codable{
    let daily : Data
}

struct Data : Codable{
    let data : [DataArray]
}

struct DataArray : Codable{
    let temperatureMin : Float
    let temperatureMax : Float
}

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let location = Location.getInstance()
        
        location.initialize()
        location.setCurrentLocationWeather()
    }


}

class Location : UIViewController, CLLocationManagerDelegate   {
    
    static var locationInstance : Location?
    var location : CLLocation?
    
    let locationManager = CLLocationManager()

    //Want to block the creation of the object from outside
    private init(){
        super.init(nibName:nil,bundle:nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //To create a singleton class (singleton design pattern)
    static func getInstance() -> Location {
        if(locationInstance == nil){
            locationInstance = Location()
        }
        return locationInstance!
    }
    
    func getLocationCoordinates() -> CLLocationCoordinate2D? {
        return location?.coordinate
    }
    
    func printCoordinates(){
        print(location?.coordinate.latitude as Any)
        print(location?.coordinate.longitude as Any)
    }
    
    func initialize(){
        
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
    }
    
    func setCurrentLocationWeather(){
        
        locationManager.startUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        location = locations[0]
        
        locationManager.stopUpdatingLocation()
        
        let weather =  Weather()
        
        weather.getData(coordinate: getLocationCoordinates())
    }
}

class Weather {
    
    func getData(coordinate : CLLocationCoordinate2D?){
        
        if let coordinate = coordinate{
            
            let apiURL = createURL(latitude : String(coordinate.latitude) , longitude : String(coordinate.longitude))
            
            if let apiURL = apiURL{
                
                let task = URLSession.shared.dataTask(with: apiURL) { (data, response, error) in
                
                    if let data = data{
                        
                        let decoder  =  JSONDecoder()
                        
                        do{
                            //decode the encoded json data to access the information
                            let weatherData = try decoder.decode(WeatherData.self, from: data)
                            
                            print(weatherData.daily.data[0].temperatureMin)
                        }
                        catch{
                            print(error)
                        }
                    }
                }
                task.resume()
            }
        }
    
    }
    
    private func createURL(latitude : String, longitude : String) -> URL? {
        
        let apiLink = "https://api.darksky.net/forecast/0f65f3e645092c5ac20efe446c738d87/" + latitude + ","
            + longitude + ",2019-12-07T03:06:00?units=ca";
        
        return URL(string: apiLink)
        
    }
}

