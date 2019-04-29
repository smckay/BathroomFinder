//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let BATHROOMS_URL = "https://data.cityofnewyork.us/resource/e4ej-j6hn.json"
    let BATHROOM_APP_ID = "946f33c4e35a4dd6e0c5d1a124987463"
    
    let LATLONG_URL = "https://api.opencagedata.com/geocode/v1/json"
    let LATLONG_APP_ID = "9b5af1ed7cf84faa849203a6b9c3c9cf"
    
    let MATRIX_URL = "https://maps.googleapis.com/maps/api/distancematrix/json"
    let MATRIX_APP_ID = "AIzaSyCUpfapAJg45q3tFhT1JLnRfH5CEIX8dbA"

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let bathroomsDataModel = BathroomsDataModel()
    
    var currentLat: Double?
    var currentLong: Double?
    var closestBathroom: BathroomDataModel?

    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    func getBathroomData(url: String, parameters: [String: String]) {
        
        Alamofire.request(url, method: .get, parameters: nil).responseJSON {
            response in
            if response.result.isSuccess {
                print("Success! Got the bathroom data")
                
                let bathroomJSON: JSON = JSON(response.result.value!)
                self.bathroomsDataModel.populateParks(json: bathroomJSON)
                
                var index: Int = 0
                for bathroom in self.bathroomsDataModel.getBathrooms(){
                    let name = bathroom.name
                    let latlongParams : [String: String] = ["key" : self.LATLONG_APP_ID, "q" : name]
                    //print("CALLING LAT LONG FUNC WITH INDEX: \(index)")
                    self.getLatLongData(url: self.LATLONG_URL, parameters: latlongParams, index: index)
                    index += 1
                }
            }
            else{
                print("Error \(response.result.error!)")
                self.cityLabel.text = "Connection Issues"
            }
        }
        
    }
    
    func getLatLongData(url: String, parameters: [String: String], index: Int) {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                //print("Success! Got the lat long data")
                
                let latlongJSON: JSON = JSON(response.result.value!)
                self.updateLatLongData(json: latlongJSON, index: index)
                var i = 0
                //if were done populating bathroom data
                if(index == self.bathroomsDataModel.bathrooms.count - 1){
                    //run through bathrooms and get distance from location to each bathroom
                    for b in self.bathroomsDataModel.bathrooms{
                        if let lat = b.lat {
                            if let long = b.long{
                                let origins : String = "\(self.currentLat!),\(self.currentLong!)"
                                let destinations : String = "\(lat),\(long)"
                                let matrixParams : [String: String] = ["units" : "imperial", "origins" : origins, "destinations" : destinations,
                                                                       "key" : self.MATRIX_APP_ID]
                                self.getDistanceData(url: self.MATRIX_URL, parameters: matrixParams, index: i)
                            }
                        }
                        else{
                            print("Latitude not retrieved for \(b.name)")
                        }
                        i += 1
                    }
                }
            }
            else{
                print("Error \(response.result.error!)")
                self.cityLabel.text = "Connection Issues"
            }
        }
    }
    
    func getDistanceData(url: String, parameters: [String: String], index: Int){
        print(parameters)
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                self.updateDistanceData(json: JSON(response.result.value!), index: index)
                if(index == self.bathroomsDataModel.bathrooms.count - 1){
                    self.closestBathroom = self.bathroomsDataModel.closestBathroom()
                    self.updateUIWithWeatherData()
                }
            }
            else{
                print("distance data not retrieved")
            }
        }
    }
    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
    
    func updateLatLongData(json: JSON, index: Int){
        let j : [JSON] = json["results"].arrayValue
        for entry in j{
            self.bathroomsDataModel.bathrooms[index].lat = entry["geometry"]["lat"].doubleValue
            self.bathroomsDataModel.bathrooms[index].long = entry["geometry"]["lng"].doubleValue
            
            break
        }
        //print("\(self.bathroomsDataModel.bathrooms[index].name) has lat: \(self.bathroomsDataModel.bathrooms[index].lat) long: \(self.bathroomsDataModel.bathrooms[index].long)")
    }
    
    func updateDistanceData(json: JSON, index: Int){
        self.bathroomsDataModel.bathrooms[index].distance = json["rows"][0]["elements"][0]["distance"]["value"].double
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData() {
        cityLabel.text = closestBathroom!.name
        //temperatureLabel.text = "\(weatherDataModel.temperature)"
        //weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        
    }
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]  
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            
            print("longitude = \(location.coordinate.longitude), latitude  = \(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            self.currentLat = Double(location.coordinate.latitude)
            self.currentLong = Double(location.coordinate.longitude)

            let locationParams : [String: String] = ["lat" : latitude, "lon" : longitude, "appid" : BATHROOM_APP_ID]
        
            getBathroomData(url: BATHROOMS_URL, parameters: locationParams)
            
        }
        
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city: String) {
        print(city)
        let params : [String: String] = ["q" : city, "appid" : BATHROOM_APP_ID]
        getBathroomData(url: BATHROOMS_URL, parameters: params)
    }
    

    
    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
    
    
    
}


