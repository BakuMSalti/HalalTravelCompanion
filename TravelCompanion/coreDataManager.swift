//
//  coreDataManager.swift
//  TravelCompanion
//
//  Created by msalti on 4/11/24.
//

import Foundation
import CoreData
class coreDataController : ObservableObject
{
    @Published var locData:[LocationCD] = [LocationCD]()
    // Handler to persistent object container
    let persistentContainer:NSPersistentContainer
    
    
    init()
    {
        persistentContainer = NSPersistentContainer(name: "tableData")
        persistentContainer.loadPersistentStores { (description, error) in
            if let error = error{
                fatalError("cannot load data \(error.localizedDescription)")
            }
            
        }
        locData = getLocation()
        
    }
    func getLocation() -> [LocationCD]{
        let fetchRequest: NSFetchRequest<LocationCD> = LocationCD.fetchRequest()
        do {
            let x = try persistentContainer.viewContext.fetch(fetchRequest)
            return x
        }catch{
            return []
        }
    }
    func findLocation(name:String, desc:String, country:String) -> LocationCD{
        var toReturn:LocationCD = LocationCD()
        for locCD in locData{
            if (locCD.name == name && locCD.desc == desc && locCD.country == country){
                toReturn = locCD;
            }
        }
        //Non void function should return a value
        return toReturn
    }
    func deleteLocation(loc :LocationCD){
        persistentContainer.viewContext.delete(loc)
        do {
            //print("saving")
            try persistentContainer.viewContext.save()
        } catch{
            print("failed to save \(error)")
        }
    }
    func saveLocation(locName:String, locDesc:String, locCountry:String){
        let locat = LocationCD(context: persistentContainer.viewContext)
        locat.name = locName;
        locat.desc = locDesc;
        locat.country = locCountry;
        
        do {
            try persistentContainer.viewContext.save()
            locData = getLocation()
        } catch{
            print("failed to save \(error)")
        }
    }
    
//    func getTotalExpenses() -> Double {
//        var total: Double = 0.0
//
//        let expenses = getExpenses()
//            for expense in expenses {
//                if expense.isSpending {
//                    total += expense.amount
//                }
//            }
//
//        return total
//    }
//    func getTotalSavings() -> Double {
//        var total: Double = 0.0
//
//        let expenses = getExpenses()
//            for expense in expenses {
//                if !expense.isSpending {
//                    total += expense.amount
//                }
//            }
//
//        return total
//    }
}
