import SwiftUI

struct ContentView: View {
    @ObservedObject var bluetoothViewModel: BluetoothViewModel
    @State private var renderedImage = UIImage(named: "rainbow")
    @State private var showingDialog = false
    @State private var hue: CGFloat?
    @State private var brightness: Double = 2.0
    
    var body: some View {
        VStack {
            PeripheralNameView(name: bluetoothViewModel.connectedPeripheral?.name ?? "Click to connect") {
                self.showingDialog = true
            }
            
            Spacer()
            
            if let image = renderedImage, bluetoothViewModel.connectedPeripheral != nil {
                ColorPickerImageView(uiImage: image, onColorChange: { newHue in
                    hue = newHue
                    sendHueToPeripheral(newHue)
                })
                
                Slider(value: $brightness, in: 0...255, step: 1)
                    .padding()
                    .onChange(of: brightness) {                        sentBrightnessToPeripheral(Int(brightness))
                    }
                    .accentColor(
                        Color(hue: hue ?? 100, saturation: 0.75, brightness: 1)
                    )
                
            }
            
            
            
            
            Spacer()
        }
        .confirmationDialog("Select a Peripheral", isPresented: $showingDialog, titleVisibility: .visible) {
            ForEach(bluetoothViewModel.peripherals, id: \.identifier) { peripheral in
                Button(peripheral.name ?? "Unknown") {
                    if peripheral.identifier == bluetoothViewModel.connectedPeripheral?.identifier {
                        bluetoothViewModel.disconnect(peripheral)
                    } else {
                        bluetoothViewModel.connect(peripheral)
                    }
                }
            }
        } message: {
            Text("Select a peripheral to connect to")
        }
        .background(Color.black)
    }
    
    private func sendHueToPeripheral(_ newHue: CGFloat?) {
        guard let connectedPeripheral = bluetoothViewModel.connectedPeripheral,
              let hueCharacteristic = bluetoothViewModel.hueCharacteristic,
              let unwrappedHue = newHue else {
            return
        }
        
        hue = unwrappedHue
        
        // Convert CGFloat to Int (0 to 255)
        let hueInt = Int(unwrappedHue * 255)
        
        // Convert Int to Data
        let dataToWrite = Data([UInt8(hueInt)])
        
        // Write the data to the characteristic
        connectedPeripheral.writeValue(dataToWrite, for: hueCharacteristic, type: .withoutResponse)
    }
    
    private func sentBrightnessToPeripheral(_ newBrightness: Int) {
        guard let connectedPeripheral = bluetoothViewModel.connectedPeripheral,
              let brightnessCharacteristic = bluetoothViewModel.brightnessCharacteristic else {
            return
        }
        
        let dataToWrite = Data([UInt8(newBrightness)])
        
        connectedPeripheral.writeValue(dataToWrite, for: brightnessCharacteristic, type: .withoutResponse)
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(bluetoothViewModel: .preview)
    }
}
