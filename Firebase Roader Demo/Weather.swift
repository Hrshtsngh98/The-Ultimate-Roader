//
//  Weather.swift
//  Ardhi
//
//  Created by Fatima Hussain on 10/13/15.
//  Copyright © 2015 Solutions 4 Mobility. All rights reserved.
//

import UIKit

typealias completionHandler = (Any) -> ()

class Weather: NSObject {
    
    static let sharedInstance = Weather()
    
    private override init() { }
    
    var temperature = 0
    var condition = Weather.Condition.Clear_sky
    enum Condition: String {
        
        case Thunderstorm_with_light_rain    =    "thunderstorm with light rain"
        case Thunderstorm_with_rain    =     "thunderstorm with rain"
        case Thunderstorm_with_heavy_rain    = "thunderstorm with heavy rain"
        case Light_thunderstorm    =    "light thunderstorm"
        case Thunderstorm    =     "thunderstorm"
        case Heavy_thunderstorm    =   "heavy thunderstorm"
        case Ragged_thunderstorm    =     "Ragged thunderstorm"
        case Thunderstorm_with_light_drizzle    =   "thunderstorm with light drizzle"
        case Thunderstorm_with_drizzle    =    "thunderstorm with drizzle"
        case Thunderstorm_with_heavy_drizzle    = "thunderstorm with heavy drizzle"
        case Light_intensity_drizzle    =  "light intensity drizzle"
        case Drizzle    =     "rainy"
        case Heavy_intensity_drizzle    =  "heavy intensity drizzle"
        case Light_intensity_drizzle_rain    =  "light intensity drizzle rain"
        case Drizzle_rain    =   "drizzle rain"
        case Heavy_intensity_drizzle_rain    =  "heavy intensity drizzle rain"
        case Shower_rain_and_drizzle    =  "shower rain and drizzle"
        case Heavy_shower_rain_and_drizzle    =   "heavy shower rain and drizzle"
        case Shower_drizzle    =   "shower drizzle"
        case Light_rain    =    "light rain"
        case Moderate_rain    =   "moderate rain"
        case Heavy_intensity_rain    =  "heavy intensity rain"
        case Very_heavy_rain    =  "very heavy rain"
        case Extreme_rain    =  "extreme rain"
        case Freezing_rain    =  "freezing rain"
        case Light_intensity_shower_rain    =  "light intensity shower rain"
        case Shower_rain    =   "shower rain"
        case Heavy_intensity_shower_rain    =   "heavy intensity shower rain"
        case Ragged_shower_rain    = "ragged shower rain"
        case Light_snow    =  "light snow"
        case Snow    =     "snow"
        case Heavy_snow    =  "heavy snow"
        case Sleet    =     "sleet"
        case Shower_sleet    =  "shower sleet"
        case Light_rain_and_snow    = "light rain and snow"
        case Rain_and_snow    =   "rain and snow"
        case Light_shower_snow    =  "light shower snow"
        case Shower_snow    =  "shower snow"
        case Heavy_shower_snow    = "heavy shower snow"
        case Mist    =     "mist"
        case Smoke    =     "smoke"
        case Haze    =     "haze"
        case Sand_dust_whirls    =   "sand, dust whirls"
        case Fog    =     "fog"
        case Sand    =     "sand"
        case Dust    =     "dust"
        case Volcanic_ash    =   "volcanic ash"
        case Squalls    =     "squalls"
        case Tornado    =     "tornado"
        case Clear_sky    =  "clear sky"
        case Few_clouds    =  "few clouds"
        case Scattered_clouds    =   "scattered clouds"
        case Broken_clouds    =   "broken clouds "
        case Overcast_clouds    =   "overcast clouds"
        case Cloud = "clouds"
        case Rain = "rain"
        
        
        var title : String {
            var title : String? = nil
            switch self {
            case .Thunderstorm_with_light_rain:   title = "thunder_storm"
            case .Thunderstorm_with_rain :   title = "thunder_storm"
            case .Thunderstorm_with_heavy_rain:   title = "thunder_storm"
            case .Light_thunderstorm:   title = "thunder_storm"
            case .Thunderstorm:   title = "thunder_storm"
            case .Heavy_thunderstorm:   title = "thunder_storm"
            case .Ragged_thunderstorm:   title = "thunder_storm"
            case .Thunderstorm_with_light_drizzle:   title = "thunder_storm"
            case .Thunderstorm_with_drizzle:   title = "thunder_storm"
            case .Thunderstorm_with_heavy_drizzle:   title = "thunder_storm"
            case .Light_intensity_drizzle:   title = "rainy"
            case .Drizzle:   title = "rainy"
            case .Heavy_intensity_drizzle:   title = "rainy"
            case .Light_intensity_drizzle_rain:   title = "rainy"
            case .Drizzle_rain:   title = "rainy"
            case .Heavy_intensity_drizzle_rain:   title = "rainy"
            case .Shower_rain_and_drizzle:   title = "rainy"
            case .Heavy_shower_rain_and_drizzle:   title = "rainy"
            case .Shower_drizzle:   title = "rainy"
            case .Light_rain:   title = "scattered_showers"
            case .Moderate_rain:   title = "scattered_showers"
            case .Heavy_intensity_rain:   title = "scattered_showers"
            case .Very_heavy_rain:   title = "scattered_showers"
            case .Extreme_rain:   title = "scattered_showers"
            case .Freezing_rain:   title = "snow"
            case .Light_intensity_shower_rain:   title = "rainy_wind"
            case .Shower_rain:   title = "rainy_wind"
            case .Heavy_intensity_shower_rain:   title = "rainy_wind"
            case .Ragged_shower_rain:   title = "rainy_wind"
            case .Light_snow:   title = "snow"
            case .Snow:   title = "snow"
            case .Heavy_snow:   title = "snow"
            case .Sleet:   title = "snow"
            case .Shower_sleet:   title = "snow"
            case .Light_rain_and_snow:   title = "snow"
            case .Rain_and_snow:   title = "snow"
            case .Light_shower_snow:   title = "snow"
            case .Shower_snow:   title = "snow"
            case .Heavy_shower_snow:   title = "snow"
            case .Mist:   title = "cold_breeze"
            case .Smoke:   title = "cold_breeze"
            case .Haze:   title = "cold_breeze"
            case .Sand_dust_whirls:   title = "cold_breeze"
            case .Fog:   title = "cold_breeze"
            case .Sand:   title = "cold_breeze"
            case .Dust:   title = "cold_breeze"
            case .Volcanic_ash:   title = "cold_breeze"
            case .Squalls:   title = "cold_breeze"
            case .Clear_sky:   title = "sun"
            case .Few_clouds:   title = "cloudy"
            case .Scattered_clouds:   title = "cloudy"
            case .Broken_clouds:   title = "cloudy"
            case .Overcast_clouds:   title = "cloudy"
            case .Cloud:   title = "cloudy"
            case .Tornado:   title = "tornado"
            case .Rain:   title = "rain"
            }
            return title!
        }
    }

    func get_weather(latitude: String, longitude: String, completion: @escaping completionHandler) {
        let url = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=b9ce58574dec9c61f4dc00348fb55fa7"
            var temperature, description: String?
            URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
                if error == nil{
                    do{
                        if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? Dictionary<String, Any>
                        {
                            let name = json["name"]
                            var weathers = json["weather"] as? [Dictionary<String,Any>]
                            var detail_conditions = json["main"] as? Dictionary<String,Any>

                            if let d = weathers![0]["description"] as? String {
                                description = d
                            }
                            
                            if let t = detail_conditions!["temp"] as? Double {
                                temperature = "\(Int(t-273.15))"
                                completion((temperature,description,name))
                            }
                        }
                    }
                    catch{
                        print("cannot parse weather")
                    }
                }
            }.resume()
        }
}


