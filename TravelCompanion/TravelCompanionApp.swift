//
//  TravelCompanionApp.swift
//  TravelCompanion
//
//  Created by msalti on 3/14/24.
//

import SwiftUI

@main
struct TravelCompanionApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(locationDataManager: LocationDataManager())
        }
    }
}
