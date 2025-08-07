//
//  ContentView.swift
//  TravelCompanion
//
//  Created by msalti on 3/14/24.
//

import SwiftUI
import CoreLocationUI
import MapKit
struct ContentView: View {
    @ObservedObject var locationDataManager : LocationDataManager
    @ObservedObject var locsSaved = locModel()
    @ObservedObject var apiCall = jsonWebVM()
    @State var currentCity:String = "Phoenix"
    @State private var selectedCountry = "United States"
    @State private var selectedCity = ""
    @State private var cityDesc = ""
    @State private var bruhLat = ""
    @State private var bruhLon = ""
    @State private var showList:Bool = false;
    @State private var showMosque:Bool = false;
    @State private var showRest:Bool = false;
    @State private var showAdd:Bool = false;
    @State private var timesArray:[String] = []
    @State private var x = false;
    @State var dataController: coreDataController = coreDataController()
    
    func reverseGeocode(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
            let location = CLLocation(latitude: latitude, longitude: longitude)
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                guard let placemark = placemarks?.first, error == nil else {
                    print("Error: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                if let city = placemark.locality {
                    self.currentCity = city
                } else {
                    self.currentCity = "City not found"
                }
            }
        }
    var body: some View {
        VStack {
            Text("Welcome to the Travel Companion!").bold()
            switch locationDataManager.locationManager.authorizationStatus {
            case .authorizedWhenInUse:  // Location services are available.
                // Insert code here of what should happen when Location services are authorized
                VStack{
                    Spacer()
                    Text("Current City: " + currentCity)
                    Spacer()
                }.onAppear{
                    bruhLat = locationDataManager.locationManager.location?.coordinate.latitude.description ?? "Error loading"
                    bruhLon = locationDataManager.locationManager.location?.coordinate.longitude.description ?? "Error loading"
                        apiCall.getTimesByCoords(Lat: bruhLat, Lon: bruhLon) { times in
                            DispatchQueue.main.async {
                                self.timesArray = times
                                self.x = true
                            }
                        }
                    reverseGeocode(latitude: locationDataManager.locationManager.location?.coordinate.latitude ?? 0.0, longitude: locationDataManager.locationManager.location?.coordinate.longitude ?? 0.0)
                    
                }
            case .restricted, .denied:  // Location services currently unavailable.
                // Insert code here of what should happen when Location services are NOT authorized
                Text("Current location data was restricted or denied.")
            case .notDetermined:        // Authorization not determined yet.
                Text("Finding your location...")
                ProgressView()
            default:
                ProgressView()
            }
            
            ZStack{
                Rectangle()
                    .fill(Color.green)
                    .frame(width: 420, height: 250, alignment: .center)
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25).stroke(Color.black, lineWidth: 5)
                    )
                if (x == true){
                    TimesView(fTime: timesArray[0], sTime: timesArray[1], dTime: timesArray[2], aTime: timesArray[3], mTime: timesArray[4], iTime: timesArray[5]).onAppear{
                        print(timesArray)}
                }
            }
            HStack{
                Spacer()
                
                Button(action: {
                    // Action to perform when the button is tapped
                    showMosque = true;
                    
                }) {
                    Image("mosque").resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 170, height: 170) // Set the size of the image
                        .foregroundColor(.white)
                }
                .background(Color.green)
                .clipShape(Circle())
                .frame(width: 170, height: 170)
                Spacer()
                Button(action: {
                    // Action to perform when the button is tapped
                    showRest = true;
                }) {
                    Image( "food").resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 170, height: 170) // Set the size of the image
                        .foregroundColor(.white)
                }
                .background(Color.green)
                .clipShape(Circle())
                .frame(width: 170, height: 170)
                Spacer()
            }.onAppear{
                for locCD in dataController.locData{
                    let l = location(name: locCD.name ?? "", desc: locCD.desc ?? "", country: locCD.country ?? "")
                    locsSaved.add(loc: l)
                }
            }
            HStack{
                Spacer()
                Text("  Find Local Mosques").bold().multilineTextAlignment(.center)
                Spacer()
                Text("   Find Local Halal Food").multilineTextAlignment(.center).bold()
                Spacer()
            }
            HStack{
                Spacer()
                
                Button(action: {
                    // Action to perform when the button is tapped
                    showAdd = true;
                }) {
                    Image( "addloc").resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 170, height: 170) // Set the size of the image
                        .foregroundColor(.white)
                }
                .background(Color.green)
                .clipShape(Circle())
                .frame(width: 170, height: 170)
                Spacer()
                Button(action: {
                    // Action to perform when the button is tapped
                    showList = true;
                }) {
                    Image("list").resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 170, height: 170)
                        .foregroundColor(.white)
                }
                .background(Color.green)
                .clipShape(Circle())
                .frame(width: 170, height: 170)
                Spacer()
            }
            HStack{
                Spacer()
                Text("Add Location").bold()
                Spacer()
                Text("   View Saved Locations    ").bold()
            }
        }.sheet(isPresented: $showList){
            NavigationView{
                List{
                    ForEach(locsSaved.locs, id : \.id){
                        location in NavigationLink(destination:DetailView(cityD: location.name, descD: location.desc, countryD: location.country, lModel: locsSaved)){
                            VStack (alignment: .leading, spacing: 5){
                                Text(location.name + ", " + location.country)
                                    .fontWeight(.semibold)
                                    .minimumScaleFactor(0.5)
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showAdd) {
            AddAlertView(thing: $showAdd, isPresented: $showAdd, selectedCity: $selectedCity, cityDesc: $cityDesc, selectedCountry: $selectedCountry, lModel: locsSaved)
        }
        .sheet(isPresented: $showMosque) {
            MosqueView(cityM: currentCity,LatM: bruhLat, LonM: bruhLon)
        }
        .sheet(isPresented: $showRest) {
            RestView(cityM: currentCity, LatM: bruhLat, LonM: bruhLon)
        }
        
    }
    
}
struct URLImageView: View {
    let url: URL
    @State private var image: UIImage?

    var body: some View {
        if let image = image {
            Image(uiImage: image)
                .resizable()
        } else {
            ProgressView()
                .onAppear(perform: loadImage)
        }
    }

    private func loadImage() {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                image = UIImage(data: data)
            }
        }.resume()
    }
}
struct MosqueView: View{
    
    
    @ObservedObject var apiCall = jsonWebVM()
    @State var cityM:String = ""
    @State var LatM:String = ""
    @State var LonM:String = ""
    @State var picture:String = "";
    @State var toDisplay:String = "";
    @State var toDisplay2:String = "";
    @State var mosqueName:[String] = []
    @State var mosqueAddy:[String] = []
    @State var mosquePics:[String] = []
    @State private var currentIndex: Int = 0
    @State private var currentIndexPics: Int = 0
    @State var q:Bool = false;
    func showNextLocation() {
        guard currentIndex < mosqueName.count - 1 else { return }
        currentIndex += 1
        updateTextField()
    }

    func showPreviousLocation() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        updateTextField()
    }

    func updateTextField() {
        toDisplay = mosqueName[currentIndex]
        toDisplay2 = mosqueAddy[currentIndex]
        picture = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference="+mosquePics[currentIndex]+"&key=Get_Your_Own_Key"
        q = false
        // Reset the q state variable after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            q = true
        }
    }
    
    var body: some View{
        
        VStack{
            Spacer()
            Text("Mosques Near \(cityM)").bold()
            Spacer()
            
            HStack{
                Spacer()
                Button {
                    showPreviousLocation()
                    
                } label: {
                    Image(systemName: "arrowshape.left.fill")
                }
                VStack{
                    Spacer()
                    if (q == true){
                        if let url = URL(string: picture) {
                            URLImageView(url: url)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 300, height: 300)
                        } else {
                            Text("Image not available")
                                .foregroundColor(.red)
                        }
                    }
                    Spacer()
                    TextField("Places near you will display here", text: $toDisplay)
                    TextField("Addresses near you will display here", text: $toDisplay2)
                    Spacer()
                    Spacer()
                }
                Button {
                    showNextLocation()
                    
                } label: {
                    Image(systemName: "arrowshape.right.fill")
                }
                Spacer()
            }
            Spacer()
        }.onAppear{
            apiCall.getMosques(Lat: LatM, Lon: LonM){ names, addresses, pics in
                mosqueName = names;
                mosqueAddy = addresses;
                mosquePics = pics
                print(mosquePics)
                updateTextField()
            }
        }
    }
}

struct RestView: View{
    
    
    @ObservedObject var apiCall = jsonWebVM()
    @State var cityM:String = ""
    @State var LatM:String = ""
    @State var LonM:String = ""
    @State var picture:String = "";
    @State var toDisplay:String = "";
    @State var toDisplay2:String = "";
    @State var mosqueName:[String] = []
    @State var mosqueAddy:[String] = []
    @State var mosquePics:[String] = []
    @State private var currentIndex: Int = 0
    @State private var currentIndexPics: Int = 0
    @State var q:Bool = false;
    func showNextLocation() {
        guard currentIndex < mosqueName.count - 1 else { return }
        currentIndex += 1
        updateTextField()
    }

    func showPreviousLocation() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        updateTextField()
    }

    func updateTextField() {
        toDisplay = mosqueName[currentIndex]
        toDisplay2 = mosqueAddy[currentIndex]
        picture = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference="+mosquePics[currentIndex]+"&key=AIzaSyC8WU0L3VojFPblAeJomlsnuTriple36fI"
        q = false
        // Reset the q state variable after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            q = true
        }
    }
    

    var body: some View{
        
        VStack{
            Spacer()
            Text("Halal Restaurants Near \(cityM)").bold()
            Spacer()
            
            HStack{
                Spacer()
                Button {
                    showPreviousLocation()
                    
                } label: {
                    Image(systemName: "arrowshape.left.fill")
                }
                VStack{
                    Spacer()
                    if (q == true){
                        if let url = URL(string: picture) {
                            URLImageView(url: url)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 300, height: 300)
                        } else {
                            Text("Image not available")
                                .foregroundColor(.red)
                        }
                    }
                    Spacer()
                    TextField("Places near you will display here", text: $toDisplay)
                    TextField("Addresses near you will display here", text: $toDisplay2)
                    Spacer()
                    Spacer()
                }
                Button {
                    showNextLocation()
                    
                } label: {
                    Image(systemName: "arrowshape.right.fill")
                }
                Spacer()
            }
            Spacer()
        }.onAppear{
            apiCall.getHalal(Lat: LatM, Lon: LonM){ names, addresses, pics in
                mosqueName = names;
                mosqueAddy = addresses;
                mosquePics = pics
                print(mosquePics)
                updateTextField()
            }
        }
    }
}
struct TimesView: View{
    
    @State var inputLat:String = ""
    @State var inputLon :String = ""
    @State var city: String = ""
    @State var country: String = ""
    @State var fTime: String = "XX:XF"
    @State var sTime: String = "XX:XS";
    @State var dTime: String = "XX:XD";
    @State var aTime: String = "XX:XA";
    @State var mTime: String = "XX:XM";
    @State var iTime: String = "XX:XI";
    @State var currP:String = "[Prayer Name]"
    @State var times :[String] = []
    
    var body: some View{
        HStack{
            Spacer()
            VStack(alignment: .leading){
                HStack{
                    Text("Fajr").bold()
                    Text(convertTo12HourFormat(timeString24h:fTime) ?? "XX:XF")
                }
                HStack{
                Text("Sunrise").bold()
                    Text(convertTo12HourFormat(timeString24h:sTime) ?? "XX:XF")
                }
                HStack{
                Text("Dhuhr").bold()
                    Text(convertTo12HourFormat(timeString24h:dTime) ?? "XX:XF")
                }
                HStack{
                Text("Asr").bold()
                    Text(convertTo12HourFormat(timeString24h:aTime) ?? "XX:XF")
                }
                HStack{
                Text("Maghrib").bold()
                    Text(convertTo12HourFormat(timeString24h:mTime) ?? "XX:XF")
                }
                HStack{
                    Text("Isha").bold()
                    Text(convertTo12HourFormat(timeString24h:iTime) ?? "XX:XF")
                }
            }
            Spacer()
            Text(currP).multilineTextAlignment(.center).bold()
            
            
            Spacer()
        }.onAppear{
            times.append(fTime)
            times.append(sTime)
            times.append(dTime)
            times.append(aTime)
            times.append(mTime)
            times.append(iTime)
            switch getCurrentPrayerTime(prayerTimes: times){
            case 0: currP = "It is currently time for \n Fajr!"
            case 1: currP = "No Prayers right now!!"
            case 2:  currP = "It is currently time for \n Dhuhr!"
            case 3: currP = "It is currently time for \n Asr!"
            case 4: currP = "It is currently time for \n Maghrib!"
            case 5: currP = "It is currently time for \n Isha!"
            default: currP = "It is currently time for \n [ERROR]!"
            }
        }
    }
    func convertTo12HourFormat(timeString24h: String) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        // Convert the 24-hour time string to a Date object
        guard let date = formatter.date(from: timeString24h) else {
            return nil // Return nil if conversion fails
        }

        // Set the date formatter to output in 12-hour format
        formatter.dateFormat = "h:mm a"

        // Convert the Date object back to a string in 12-hour format
        return formatter.string(from: date)
    }
    func getCurrentPrayerTime(prayerTimes: [String]) -> Int {
       
            //imagine the following ["04:48", "05:59", "12:29", "16:06", "18:58", "20:10"] and currenttime is 14:47
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        // Create an empty array to store the converted Date objects
        var dateArray: [Date] = []

        // Iterate over each time string and convert it to a Date object
        for timeString in prayerTimes {
            if let date = formatter.date(from: timeString) {
                dateArray.append(date)
            } else {
                print("Error converting time string: \(timeString)")
            }
        }
        let currentTimeString1 = formatter.string(from: Date())
        let currentTimeString = formatter.date(from: currentTimeString1)
        if (currentTimeString! > dateArray[0] && currentTimeString! < dateArray[1]){//if between fajr and sunrise time
            return 0;//it fajr time
        } else if (currentTimeString! > dateArray[1] && currentTimeString! < dateArray[2]){//if between sunrise and dhuhr time
            return 1;//no time
        } else if (currentTimeString! > dateArray[2] && currentTimeString! < dateArray[3]){//if between fajr and sunrise time
            return 2;//dhuhr time
        } else if (currentTimeString! > dateArray[3] && currentTimeString! < dateArray[4]){//if between fajr and sunrise time
            return 3;//asr time
        } else if (currentTimeString! > dateArray[4] && currentTimeString! < dateArray[5]){//if between fajr and sunrise time
            return 4;//maghrib time
        } else if (currentTimeString! > dateArray[5]){//if between fajr and sunrise time
            return 5;//isha time
        }
        return -1;
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(locationDataManager: LocationDataManager())
    }
}
