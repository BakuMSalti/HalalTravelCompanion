//
//  jsonWebVM.swift
//  TravelCompanion
//
//  Created by msalti on 4/9/24.
//

import Foundation
struct PrayerResponse: Decodable {
    let data: PrayerData
}

struct PrayerData: Decodable {
    let timings: Timings
}

struct Timings: Decodable {
    let Fajr: String
    let Sunrise: String
    let Dhuhr: String
    let Asr: String
    let Maghrib: String
    let Isha: String
}


class jsonWebVM : ObservableObject{
    
    func getTimesByCoords(Lat: String, Lon:String, completion: @escaping ([String]) -> Void)  {
            var toReturn: [String] = []
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            
            let currDate = Date()
            let dateString = dateFormatter.string(from: currDate)
            let urlAsString = "https://api.aladhan.com/v1/timings/"+dateString+"?latitude="+Lat+"&longitude="+Lon+"&method=2"
            
            if let url = URL(string: urlAsString) {
                let task = URLSession.shared.dataTask(with: url) { data, response, error in
                    guard let data = data, error == nil else {
                        print("Error: \(error?.localizedDescription ?? "Unknown error")")
                        completion([])
                        return
                    }
                    
                    do {
                        let decoder = JSONDecoder()
                        let result = try decoder.decode(PrayerResponse.self, from: data)
                        
                        // Add prayer timings to the toReturn array
                        toReturn.append(result.data.timings.Fajr)
                        toReturn.append(result.data.timings.Sunrise)
                        toReturn.append((result.data.timings.Dhuhr))
                        toReturn.append((result.data.timings.Asr))
                        toReturn.append((result.data.timings.Maghrib))
                        toReturn.append((result.data.timings.Isha))
                        completion(toReturn)
                    } catch {
                        print("Error decoding JSON: \(error)")
                        completion([])
                    }
                }
                task.resume()
            }
            
        }
    
    func getTimesByCity(City: String, Country: String, completion: @escaping ([String]) -> Void) {
        var toReturn: [String] = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        let currDate = Date()
        let dateString = dateFormatter.string(from: currDate)
        
        // Encode city and country names for URL
        guard let encodedCity = City.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedCountry = Country.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Error encoding city or country")
            completion([])
            return
        }
        
        let urlAsString = "https://api.aladhan.com/v1/timingsByCity/\(dateString)?city=\(encodedCity)&country=\(encodedCountry)&method=2"
        print(urlAsString)
        
        if let url = URL(string: urlAsString) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else {
                    print("Error: \(error?.localizedDescription ?? "Unknown error")")
                    completion([])
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(PrayerResponse.self, from: data)
                    
                    // Add prayer timings to the toReturn array
                    toReturn.append(result.data.timings.Fajr)
                    toReturn.append(result.data.timings.Sunrise)
                    toReturn.append(result.data.timings.Dhuhr)
                    toReturn.append(result.data.timings.Asr)
                    toReturn.append(result.data.timings.Maghrib)
                    toReturn.append(result.data.timings.Isha)
                    
                    completion(toReturn)
                } catch {
                    print("Error decoding JSON: \(error)")
                    completion([])
                }
            }
            task.resume()
        }
    }
 //=============================================MAPS API========================================================//
    //https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=33,-112&radius=80000&type=mosque&key=Get_Your_Own_Key
    
    struct MapsResponse: Decodable {
        let results: [Places]
    }
    struct Places:Decodable{
        let name: String;
        let photos: [Photo]
        let types: [String];
        let vicinity:String;
    }
    struct MapsResponse2: Decodable {
        let results: [Places2]
    }
    struct Places2:Decodable{
        let name: String;
        let types: [String];
        let vicinity:String;
    }
    struct Photo:Decodable{
        let photo_reference:String;
    }

    func getMosques(Lat: String, Lon: String, completion: @escaping ([String], [String], [String]) -> Void) {
        let urlAsString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(Lat),\(Lon)&radius=80000&type=mosque&key=AIzaSyC8WU0L3VojFPblAeJomlsnuTriple36fI"
        print(urlAsString)
        guard let url = URL(string: urlAsString) else {
            completion([], [], [])
            return
        }
        
        let urlSession = URLSession.shared
        
        let jsonQuery = urlSession.dataTask(with: url) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                completion([], [], [])
                return
            }
            
            do {
                let mosquesResponse = try JSONDecoder().decode(MapsResponse.self, from: data!)
                
                // Extract names and addresses from the response
                let names = mosquesResponse.results.map { $0.name }
                let addresses = mosquesResponse.results.map { $0.vicinity }
                let pictures = mosquesResponse.results.map {$0.photos[0].photo_reference}
                completion(names, addresses, pictures)
            } catch {
                print("Error decoding JSON: \(error)")
                completion([], [], [])
            }
        }
        
        jsonQuery.resume()
    }
    func getMosquesNoPics(Lat: String, Lon: String, completion: @escaping ([String], [String]) -> Void) {
        let urlAsString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(Lat),\(Lon)&radius=80000&type=mosque&key=AIzaSyC8WU0L3VojFPblAeJomlsnuTriple36fI"
        print(urlAsString)
        guard let url = URL(string: urlAsString) else {
            completion([], [])
            return
        }
        
        let urlSession = URLSession.shared
        
        let jsonQuery = urlSession.dataTask(with: url) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                completion([], [])
                return
            }
            
            do {
                let mosquesResponse = try JSONDecoder().decode(MapsResponse2.self, from: data!)
                
                // Extract names and addresses from the response
                let names = mosquesResponse.results.map { $0.name }
                let addresses = mosquesResponse.results.map { $0.vicinity }
                completion(names, addresses)
            } catch {
                print("Error decoding JSON: \(error)")
                completion([], [])
            }
        }
        
        jsonQuery.resume()
    }
    
    func getHalal(Lat: String, Lon: String, completion: @escaping ([String], [String], [String]) -> Void) {
        let urlAsString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(Lat),\(Lon)&radius=80000&type=restaurant&keyword=halal&key=AIzaSyC8WU0L3VojFPblAeJomlsnuTriple36fI"
        print(urlAsString)
        guard let url = URL(string: urlAsString) else {
            completion([], [],[])
            return
        }
        
        let urlSession = URLSession.shared
        
        let jsonQuery = urlSession.dataTask(with: url) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                completion([], [],[])
                return
            }
            
            do {
                let mosquesResponse = try JSONDecoder().decode(MapsResponse.self, from: data!)
                
                // Extract names and addresses from the response
                let names = mosquesResponse.results.map { $0.name }
                let addresses = mosquesResponse.results.map { $0.vicinity }
                let pictures = mosquesResponse.results.map {$0.photos[0].photo_reference}
                completion(names, addresses, pictures)
            } catch {
                print("Error decoding JSON: \(error)")
                completion([], [],[])
            }
        }
        
        jsonQuery.resume()
    }
    
    func getHalalNoPics(Lat: String, Lon: String, completion: @escaping ([String], [String]) -> Void) {
        let urlAsString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(Lat),\(Lon)&radius=80000&type=restaurant&keyword=halal&key=AIzaSyC8WU0L3VojFPblAeJomlsnuTriple36fI"
        print(urlAsString)
        guard let url = URL(string: urlAsString) else {
            completion([], [])
            return
        }
        
        let urlSession = URLSession.shared
        
        let jsonQuery = urlSession.dataTask(with: url) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                completion([], [])
                return
            }
            
            do {
                let mosquesResponse = try JSONDecoder().decode(MapsResponse2.self, from: data!)
                
                // Extract names and addresses from the response
                let names = mosquesResponse.results.map { $0.name }
                let addresses = mosquesResponse.results.map { $0.vicinity }
                completion(names, addresses)
            } catch {
                print("Error decoding JSON: \(error)")
                completion([], [])
            }
        }
        
        jsonQuery.resume()
    }
//    func getRest(Lat: String, Lon: String, completion: @escaping ([String], [String]) -> Void) {
//        let urlAsString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(Lat),\(Lon)&radius=80000&type=restaurant&key=YOUR_API_KEY"
//        print(urlAsString)
//        guard let url = URL(string: urlAsString) else {
//            completion([], [])
//            return
//        }
//
//        let urlSession = URLSession.shared
//
//        let jsonQuery = urlSession.dataTask(with: url) { data, response, error in
//            if let error = error {
//                print(error.localizedDescription)
//                completion([], [])
//                return
//            }
//
//            do {
//                let mosquesResponse = try JSONDecoder().decode(MapsResponse.self, from: data!)
//
//                // Filter out places that have "lodging" in their types array
//                let filteredResults = mosquesResponse.results.filter { !$0.types.contains("lodging") }
//
//                // Extract names and addresses from the filtered results
//                let names = filteredResults.map { $0.name }
//                let addresses = filteredResults.map { $0.vicinity }
//
//                completion(names, addresses)
//            } catch {
//                print("Error decoding JSON: \(error)")
//                completion([], [])
//            }
//        }
//
//        jsonQuery.resume()
//    }
//
//
}
