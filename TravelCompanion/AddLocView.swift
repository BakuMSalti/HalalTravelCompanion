//
//  AddLocView.swift
//  TravelCompanion
//
//  Created by msalti on 4/11/24.
//

import SwiftUI

struct AddLocView: View {
    @Binding var addAlertA:Bool;
    @Binding var addLocA:Bool;
    @Binding var selectedCity: String
    @Binding var cityDesc: String
    @Binding var selectedCountry: String
    @ObservedObject var lModel = locModel()
    @ObservedObject var apiCall = jsonWebVM()
    @State private var timesArray:[String] = []
    @State private var x = false;
    @State var dataController: coreDataController = coreDataController()
    var body: some View {
        VStack {
            Text("In " + selectedCity + " ," + selectedCountry).bold().onAppear{
                apiCall.getTimesByCity(City: selectedCity, Country: selectedCountry) { times in
                    DispatchQueue.main.async {
                        self.timesArray = times
                        self.x = true
                    }
                }
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
            Button(action: {
                // Action to perform when the button is tapped
                lModel.add(loc: location(name: selectedCity,desc: cityDesc, country: selectedCountry))
                dataController.saveLocation(locName: selectedCity, locDesc: cityDesc, locCountry: selectedCountry)
                addLocA = false;
                addAlertA = false;
            }) {
                Text("Confirm Add")
            }
        }
    }
}
struct AddAlertView: View {
    @Binding var thing:Bool;
    @Binding var isPresented: Bool
    @Binding var selectedCity: String
    @Binding var cityDesc: String
    @Binding var selectedCountry: String
    @ObservedObject var lModel = locModel()
    @State private var showConfirmAdd:Bool = false;
    let countries = [
        "Afghanistan", "Albania", "Algeria", "Andorra", "Angola", "Antigua and Barbuda", "Argentina", "Armenia", "Australia", "Austria", "Azerbaijan",
        "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bhutan", "Bolivia", "Bosnia and Herzegovina", "Botswana", "Brazil", "Brunei", "Bulgaria", "Burkina Faso", "Burundi",
        "Cabo Verde", "Cambodia", "Cameroon", "Canada", "Central African Republic", "Chad", "Chile", "China", "Colombia", "Comoros", "Congo", "Costa Rica", "Croatia", "Cuba", "Cyprus", "Czechia",
        "Democratic Republic of the Congo", "Denmark", "Djibouti", "Dominica", "Dominican Republic",
        "Ecuador", "Egypt", "El Salvador", "Equatorial Guinea", "Eritrea", "Estonia", "Eswatini", "Ethiopia","Fiji", "Finland", "France",
        "Gabon", "Gambia", "Georgia", "Germany", "Ghana", "Greece", "Grenada", "Guatemala", "Guinea", "Guinea-Bissau", "Guyana","Haiti", "Honduras", "Hungary",
        "Iceland", "India", "Indonesia", "Iran", "Iraq", "Ireland", "Italy",
        "Jamaica", "Japan", "Jordan",
        "Kazakhstan", "Kenya", "Kiribati", "Kuwait", "Kyrgyzstan",
        "Laos", "Latvia", "Lebanon", "Lesotho", "Liberia", "Libya", "Liechtenstein", "Lithuania", "Luxembourg",
        "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Mauritania", "Mauritius", "Mexico", "Micronesia", "Moldova", "Monaco", "Mongolia", "Montenegro", "Morocco", "Mozambique", "Myanmar",
        "Namibia", "Nauru", "Nepal", "Netherlands", "New Zealand", "Nicaragua", "Niger", "Nigeria", "North Korea", "North Macedonia", "Norway",
        "Oman","Pakistan", "Palau", "Palestine", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines", "Poland", "Portugal",
        "Qatar", "Romania", "Russia", "Rwanda",
        "Saint Kitts and Nevis", "Saint Lucia", "Saint Vincent and the Grenadines", "Samoa", "San Marino", "Sao Tome and Principe", "Saudi Arabia", "Senegal", "Serbia", "Seychelles", "Sierra Leone", "Singapore", "Slovakia", "Slovenia", "Solomon Islands", "Somalia", "South Africa", "South Korea", "South Sudan", "Spain", "Sri Lanka", "Sudan", "Suriname", "Sweden", "Switzerland", "Syria",
        "Taiwan", "Tajikistan", "Tanzania", "Thailand", "Timor-Leste", "Togo", "Tonga", "Trinidad and Tobago", "Tunisia", "Turkey", "Turkmenistan", "Tuvalu",
        "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom", "United States", "Uruguay", "Uzbekistan",
        "Vanuatu", "Vatican City", "Venezuela", "Vietnam","Yemen", "Zambia", "Zimbabwe"
    ]
    var body: some View {
        VStack {
            HStack{
                TextField("City Add:", text: $selectedCity)
                
                Picker("Select a country", selection: $selectedCountry) {
                    ForEach(countries, id: \.self) { country in
                        Text(country)
                    }
                }
            }
            TextField("Add a short decription:", text: $cityDesc)
            HStack {
                Spacer()
                Button("Insert") {
                    showConfirmAdd = true
                    // Perform insert action
                }
                Spacer()
                Button("Cancel") {
                    thing = false
                    // Perform insert action
                }
                Spacer()
                
            }.sheet(isPresented: $showConfirmAdd) {
                AddLocView(addAlertA: $thing, addLocA: $showConfirmAdd, selectedCity: $selectedCity, cityDesc: $cityDesc, selectedCountry: $selectedCountry, lModel: lModel)
            }
        }
        .padding()
    }
}
