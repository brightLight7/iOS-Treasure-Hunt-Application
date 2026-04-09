//
//  PedometerService.swift
//  Treasure-Hunt_Application
//
//  Created by Reda Ejhani on 06/04/2026.
//

import Foundation
import Combine
import CoreMotion

// MARK: - PedometerService

final class PedometerService: ObservableObject {
    
    @Published var stepCount: Int = 0
    @Published var distance: Double = 0
    @Published var isTracking = false
    @Published var isAvailable = CMPedometer.isStepCountingAvailable()
    
    private let pedometer = CMPedometer()
    private var sessionStart: Date?
    
    func startSession() {
        guard CMPedometer.isStepCountingAvailable() else { return }
        sessionStart = Date()
        stepCount = 0
        distance = 0
        isTracking = true
        
        pedometer.startUpdates(from:Date()) { [weak self] data, error in
            guard let self, let data, error == nil else { return }
            DispatchQueue.main.async {
                self.stepCount = data.numberOfSteps.intValue
                self.distance = data.distance?.doubleValue ?? 0
            }
        }
    }
    
    func stopSession() {
        pedometer.stopUpdates()
        isTracking = false
    }
}

