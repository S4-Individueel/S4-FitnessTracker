//
//  ContentView.swift
//  S4-FitnessTracker
//
//  Created by Reno Muijsenberg on 14/02/2023.
//
import SwiftUI
import CoreMotion

struct ContentView: View {
    //Pedometer object of the Core Motion package
    private let pedometer: CMPedometer = CMPedometer()
    
    //Variables to update step count in view
    @State private var stepsLastSevenDays: Int?
    @State private var stepsThisMorning: Int?
    @State private var stepsFromBoot: Int?
    @State private var stepsThisDay: Int?
    
    //Get time zone of user.
    var localTimeZoneAbbreviation: String { return TimeZone.current.abbreviation() ?? "" }

    
    //Check if pedometer is availible on device
    private var isPedometerAvailible: Bool {
        return CMPedometer.isPedometerEventTrackingAvailable() && CMPedometer.isStepCountingAvailable() && CMPedometer.isDistanceAvailable()
    }
    
    //Function to init pedometer on startup
    private func initializePedometer() {
        if isPedometerAvailible {
            getSetpsFromLastSevenDays()
            getStepsFromThisMorning()
            getStepsFromThisDay()
            getStepsFromDeviceBoot()
        }
    }
    
    //Function to het step from last seven days till now
    private func getSetpsFromLastSevenDays() -> Void {
        //Get todays date -7 days
        guard let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) else { return }
        
        //Query pedometer for steps from start date till now
        pedometer.queryPedometerData(from: startDate, to: Date()) { data, error in guard let data = data, error == nil else {return}
            stepsLastSevenDays = data.numberOfSteps.intValue
        }
    }
    
    //Function to get steps from 00.00 till 12.00 this day
    private func getStepsFromThisMorning() -> Void {
        // Get the start of today in the user's local time zone
        guard let startDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date()) else { return }

        // Get the date with time set to 12:00:00 in the user's local time zone
        guard let endDate = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: startDate) else { return }
        
        pedometer.queryPedometerData(from: startDate, to: endDate) { data, error in guard let data = data, error == nil else {return}
            stepsThisMorning = data.numberOfSteps.intValue
        }
    }
    
    //Function to get steps from 00.00 till 12.00 this day
    private func getStepsFromThisDay() -> Void {
        // Get the start of today in the user's local time zone
        guard let startDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date()) else { return }

        // Get the date with time set to 23:59:59 in the user's local time zone
        guard let endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: startDate) else { return }
        
        pedometer.queryPedometerData(from: startDate, to: endDate) { data, error in guard let data = data, error == nil else {return}
            stepsThisDay = data.numberOfSteps.intValue
        }
    }
    
    private func getStepsFromDeviceBoot() -> Void {
        //Get boot time of device and store in variable
        guard let bootTime = Calendar.current.date(byAdding: .second, value: Int(-ProcessInfo.processInfo.systemUptime), to: Date()) else { return }
    
        //Get pedometer data from boot of device till now
        pedometer.queryPedometerData(from: bootTime, to: Date()) { data, error in guard let data = data, error == nil else {return}
            stepsFromBoot = data.numberOfSteps.intValue
        }
    }
    
    var body: some View {
        VStack {
            Text("Step counter stats:").font(.title)
            List {
                HStack {
                    Text("Steps set last 7 days:")
                    Spacer()
                    Text(stepsLastSevenDays != nil ?  "\(stepsLastSevenDays!)" : "0")
                }.padding()
                
                HStack {
                    Text("Steps set this morning:")
                    Spacer()
                    Text(stepsThisMorning != nil ?  "\(stepsThisMorning!)" : "0")
                }.padding()
                
                HStack {
                    Text("Steps set this day:")
                    Spacer()
                    Text(stepsThisDay != nil ?  "\(stepsThisDay!)" : "0")
                }.padding()
                
                HStack {
                    Text("Steps set from boot of device:")
                    Spacer()
                    Text(stepsFromBoot != nil ?  "\(stepsFromBoot!)" : "0")
                }.padding()
            }
            .refreshable {
                initializePedometer()
            }
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
