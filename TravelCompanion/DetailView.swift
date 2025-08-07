//
//  DetailView.swift
//  TravelCompanion
//
//  Created by msalti on 4/11/24.
//

import SwiftUI
import MapKit

struct Location: Identifiable {
    let id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D
}
struct MosqueAndFoodView :View{
    @ObservedObject var apiCall = jsonWebVM()
    @State private var currentIndex: Int = 0
    @State var MFLat:String = "";
    @State var MFLon:String = "";
    @State var cityMF:String = "";
    @State var countryMF:String = "";
    @State var toDisplay:String = "";
    @State var toDisplay2:String = "";
    @State var toDisplay3:String = "";
    @State var toDisplay4:String = "";
    @State var restName:[String] = []
    @State var restAddy:[String] = []
    @State var mosqueName:[String] = []
    @State var mosqueAddy:[String] = []
    @State var dummy:[String]=[]
    let muslimMajorityCountries = ["Afghanistan", "Albania", "Algeria", "Azerbaijan", "Bahrain", "Bangladesh", "Brunei", "Burkina Faso", "Comoros", "Djibouti", "Egypt", "Gambia", "Indonesia", "Iran", "Iraq", "Jordan", "Kazakhstan", "Kuwait", "Kyrgyzstan", "Lebanon", "Libya", "Malaysia", "Maldives", "Mali", "Mauritania", "Morocco", "Niger", "Nigeria", "Oman", "Pakistan", "Palestine", "Qatar", "Saudi Arabia", "Senegal", "Sierra Leone", "Somalia", "Sudan", "Syria", "Tajikistan", "Tunisia", "Turkey", "Turkmenistan", "United Arab Emirates", "Uzbekistan", "Yemen"]

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
    }
    
    func showNextLocation2() {
        guard currentIndex < restName.count - 1 else { return }
        currentIndex += 1
        updateTextField2()
    }

    func showPreviousLocation2() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        updateTextField2()
    }

    func updateTextField2() {
        toDisplay3 = restName[currentIndex]
        toDisplay4 = restAddy[currentIndex]
    }
    var body : some View{
        VStack{
            Text("Mosques Near \(cityMF)").bold()
            HStack{
                Spacer()
                Button {
                    showPreviousLocation()
                    
                } label: {
                    Image(systemName: "arrowshape.left.fill")
                }
                VStack{
                    TextField("Places near you will display here", text: $toDisplay)
                    TextField("Addresses near you will display here", text: $toDisplay2)
                }
                Button {
                    showNextLocation()
                    
                } label: {
                    Image(systemName: "arrowshape.right.fill")
                }
                Spacer()
            }
            Text("Halal Food Near \(cityMF)").bold()
            HStack{
                Spacer()
                Button {
                    showPreviousLocation2()
                    
                } label: {
                    Image(systemName: "arrowshape.left.fill")
                }
                VStack{
                    TextField("Places near you will display here", text: $toDisplay3)
                    TextField("Addresses near you will display here", text: $toDisplay4)
                }
                Button {
                    showNextLocation2()
                    
                } label: {
                    Image(systemName: "arrowshape.right.fill")
                }
                Spacer()
            }
        }.onAppear{
            apiCall.getMosquesNoPics(Lat: MFLat, Lon: MFLon){ names, addresses in
                mosqueName = names;
                mosqueAddy = addresses;
                print(mosqueName)
                print(mosqueAddy)
                updateTextField()
            }
            apiCall.getHalalNoPics(Lat: MFLat, Lon: MFLon){ names, addresses in
                restName = names;
                restAddy = addresses;
                updateTextField2()
            }
        }
    }
}
struct DetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var apiCall = jsonWebVM()
    @State private var timesArray:[String] = []
    @State private var x = false;
    @State private var coordsPopulated = false;
    let cityD: String
    let descD:String
    let countryD: String
    @State var restName:[String] = []
    @State var restAddy:[String] = []
    @State var mosqueName:[String] = []
    @State var mosqueAddy:[String] = []
    @ObservedObject  var lModel : locModel
    @State var cityLat:String = "";
    @State var cityLon:String = "";
    @State var dataController: coreDataController = coreDataController()
    @State private static var defaultLocation = CLLocationCoordinate2D(
        latitude: 0,
        longitude: 0
    )
    func forwardGeocoding(addressStr: String)
    {
        _ = CLGeocoder();
        let addressString = addressStr
        CLGeocoder().geocodeAddressString(addressString, completionHandler:
                                            {(placemarks, error) in
            
            if error != nil {
                print("Geocode failed: \(error!.localizedDescription)")
            } else if placemarks!.count > 0 {
                let placemark = placemarks![0]
                let location = placemark.location
                let coords = location!.coordinate
                
                cityLat = coords.latitude.description
                print(cityLat + " IS CITYLAT")
                cityLon = coords.longitude.description
                print(cityLon + " IS CITYLON")
                coordsPopulated = true;
                DispatchQueue.main.async{
                    region.center = coords
                    markers[0].name = placemark.locality ?? ""
                    markers[0].coordinate = coords
                }
            }
        })
    }
    // state property that represents the current map region
    @State private var region = MKCoordinateRegion(
        center: defaultLocation,
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    @State private var markers = [
        Location(name: "What", coordinate: defaultLocation)
    ]
//    func showNextLocation() {
//        guard currentIndex < places.count - 1 else { return }
//        currentIndex += 1
//        updateTextField()
//    }
//
//    func showPreviousLocation() {
//        guard currentIndex > 0 else { return }
//        currentIndex -= 1
//        updateTextField()
//    }
//
//    func updateTextField() {
//        toDisplay = places[currentIndex].name
//    }
    var body: some View {
        VStack{
            Text("\(cityD): \(descD) ")
            Map(coordinateRegion: $region,
                interactionModes: .all
                ,annotationItems: markers
            ){ location in
                MapMarker(coordinate: location.coordinate)
                
            }
            if (x == true){
                TimesView(fTime: timesArray[0], sTime: timesArray[1], dTime: timesArray[2], aTime: timesArray[3], mTime: timesArray[4], iTime: timesArray[5])
            }
            if (coordsPopulated == true){
                MosqueAndFoodView(MFLat: cityLat, MFLon: cityLon, cityMF: cityD, countryMF:  countryD)
            }
        }.onAppear{
            forwardGeocoding(addressStr: cityD)
            apiCall.getTimesByCity(City: cityD, Country: countryD) { times in
                DispatchQueue.main.async {
                    self.timesArray = times
                    print(timesArray)
                    self.x = true
                }
            }
            
        }
            .navigationTitle(cityD)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .destructive) {
                        let x = lModel.findLoc(inp: cityD)
                        print(x)
                        let toDeleteCD = dataController.findLocation(name: cityD, desc: descD, country: countryD)
                        if (toDeleteCD != LocationCD()){//if it aint empty
                            dataController.deleteLocation(loc: toDeleteCD)
                        }
                        lModel.removeLoc(at: x)
                    
                        dismiss()
                        
                        
                    } label: {
                        Image(systemName: "trash")
                    }

                }
            }
    }
}


