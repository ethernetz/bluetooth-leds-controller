import SwiftUI

struct ContentView: View {
    @ObservedObject var bluetoothViewModel: BluetoothViewModel
    @State private var renderedImage = UIImage(named: "rainbow")
    @State private var showingDialog = false
    @State private var hue: CGFloat?
    
    var body: some View {
        VStack {
            PeripheralNameView(name: bluetoothViewModel.connectedPeripheral?.name ?? "Click to connect") {
                self.showingDialog = true
            }
            
            Spacer()
            
            if let image = renderedImage, bluetoothViewModel.connectedPeripheral != nil {
                ColorPickerImageView(uiImage: image, onColorChange: { newHue in
                    handleHueChange(newHue)
                })
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
    
    private func handleHueChange(_ newHue: CGFloat?) {
        guard let connectedPeripheral = bluetoothViewModel.connectedPeripheral,
              let hueCharacteristic = bluetoothViewModel.hueCharacteristic,
              let unwrappedHue = newHue else {
            return
        }
        
        // Convert CGFloat to Int (0 to 255)
        let hueInt = Int(unwrappedHue * 255)
        
        // Convert Int to Data
        let dataToWrite = Data([UInt8(hueInt)])
        
        // Write the data to the characteristic
        connectedPeripheral.writeValue(dataToWrite, for: hueCharacteristic, type: .withoutResponse)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(bluetoothViewModel: .preview)
    }
}
