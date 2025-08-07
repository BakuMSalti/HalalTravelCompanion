//
//  locModel.swift
//  TravelCompanion
//
//  Created by msalti on 3/14/24.
//

import Foundation

struct location: Identifiable{
    var id = UUID()
    var name = String() //nanme of city
    var desc = String() //city desfc
    var country = String() //name of city's country
}

public class locModel: ObservableObject {
    @Published var locs = [location(name: "Phoenix",desc: "Capital of Arizona", country: "United States")]
//        location(name: "Phoenix",desc: "Capital of Arizona", country: "United States"),location(name: "Mecca",desc: "Home of Masjid Al-Haram,", country: "Saudi Arabia"),location(name: "Jakarta",desc: "Capital of Indonesia", country: "Indonesia"),location(name: "Cairo",desc: "Capital of Egypt", country: "Egypt")
    
    
    var count: Int {
        locs.count
    }
    
    func getLoc(at index: Int) -> location {
        return locs[index]
    }
    
    func add(loc: location) {
        locs.append(loc)
    }
    
     func removeLoc(at index: Int) {
        locs.remove(at: index)
    }
    func findLoc(inp: String) -> Int{
        var loc:Int = 0
        print(inp)
        for f in locs
        {
            if f.name == inp
            {
                break;
              
            }
            loc = loc + 1
            print(loc)
        }
        return loc
    }
}
