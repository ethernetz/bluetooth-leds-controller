//
//  led_controllerApp.swift
//  led-controller
//
//  Created by Ethan Netz on 1/23/24.
//

import SwiftUI

@main
struct led_controllerApp: App {
    var body: some Scene {
        WindowGroup {
            let bluetoothViewModel = BluetoothViewModel()
            ContentView(bluetoothViewModel: bluetoothViewModel)
                .environment(\.colorScheme, .light)
        }
    }
}
