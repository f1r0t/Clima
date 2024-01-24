//
//  WeatherManager.swift
//  Clima
//
//  Created by Fırat AKBULUT on 16.09.2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    
    let weatherUrl = "https://api.openweathermap.org/data/2.5/weather?appid=(yourapikey)&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String){
        let urlString = "\(weatherUrl)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        let urlString = "\(weatherUrl)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString )
    }
    
    func performRequest(with urlString: String){
        // 1. Create a URL
        if let url = URL(string: urlString) {
            // 2. Create a URLSession
            let session = URLSession(configuration: .default)
            // 3. Give the session a task
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    print(error!)
                }
                if let safeData = data {
                    if let weather = parseJson(safeData){
                        delegate?.didUpdateWeather(weather: weather)
                    }
                }
            }
            // 4. Start the task
            task.resume()
        }
    }
    func parseJson(_ weatherData: Data) -> WeatherModel? {
        do {
            let decodedData = try JSONDecoder().decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temperature = decodedData.main.temp
            let cityName = decodedData.name
            let weather = WeatherModel(conditionId: id, cityName: cityName, temperature: temperature)
            return weather
        } catch  {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
