//
//  ContentView.swift
//  S4-FitnessTracker
//
//  Created by Reno Muijsenberg on 14/02/2023.
//

import SwiftUI
import CoreMotion


struct ContentView: View {
    private let pedometer: CMPedometer = CMPedometer()
    
    @State private var steps: Int?
    
    private var isPedometerAvailible: Bool {
        return CMPedometer.isPedometerEventTrackingAvailable() && CMPedometer.isStepCountingAvailable() && CMPedometer.isDistanceAvailable()
    }
    
    private func initializePedometer() {
        if isPedometerAvailible {
            guard let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) else { return }
            
            pedometer.queryPedometerData(from: startDate, to: Date()) { data, error in guard let data = data, error == nil else {return}
                steps = data.numberOfSteps.intValue
            }
        }
    }
    
    var body: some View {
        VStack {
            Text(steps != nil ? "Steps set last 7 days: \(steps!)" : "Steps set last 7 days: 0").padding()
            
            .onAppear {
                initializePedometer()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
