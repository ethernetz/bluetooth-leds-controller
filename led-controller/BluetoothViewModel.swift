import CoreBluetooth

let serviceUUID = CBUUID(string: "4fafc201-1fb5-459e-8fcc-c5c9c331914b")
let hueCharacteristicUUID = CBUUID(string: "beb5483e-36e1-4688-b7f5-ea07361b26a8")

class BluetoothViewModel: NSObject, ObservableObject {
    private var centralManager: CBCentralManager?
    @Published var connectedPeripheral: PeripheralProtocol?
    @Published var peripherals: [PeripheralProtocol] = []
    
    var hueCharacteristic: CBCharacteristic?
    
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: .main)
    }
    
    func connect(_ peripheral: PeripheralProtocol) {
        guard let cbPeripheral = peripheral as? CBPeripheral else { return }
        self.centralManager?.connect(cbPeripheral, options: nil)
    }
    
    func disconnect(_ peripheral: PeripheralProtocol) {
        guard let cbPeripheral = peripheral as? CBPeripheral else { return }
        self.centralManager?.cancelPeripheralConnection(cbPeripheral)
    }
}

extension BluetoothViewModel: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            self.centralManager?.scanForPeripherals(withServices: [serviceUUID])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        DispatchQueue.main.async {
            if !self.peripherals.contains(where: { $0.identifier == peripheral.identifier }) {
                self.peripherals.append(peripheral)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        DispatchQueue.main.async {
            self.connectedPeripheral = peripheral
            peripheral.delegate = self
            peripheral.discoverServices(nil)  // Discover all services
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        DispatchQueue.main.async {
            if peripheral.identifier == self.connectedPeripheral?.identifier {
                self.connectedPeripheral = nil
            }
        }
    }
}

extension BluetoothViewModel: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)  // Discover all characteristics
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.uuid == hueCharacteristicUUID {
                
                print("Found the hue characteristic");
                if !characteristic.properties.contains(.writeWithoutResponse) {
                    print("hueCharacteristic has the wrong properties")
                    return
                }
                hueCharacteristic = characteristic
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let value = characteristic.value {
            // Handle the characteristic value
            print("Got value: \(value)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        // Handle write confirmation
        print("Value written to \(characteristic)")
    }
}


extension BluetoothViewModel {
    static var preview: BluetoothViewModel {
        let viewModel = BluetoothViewModel()
        // Add your mock peripherals here
        viewModel.peripherals = [
            MockPeripheral(identifier: UUID(), name: "Mock Peripheral 1"),
            MockPeripheral(identifier: UUID(), name: "Mock Peripheral 2")
            // Add more mock peripherals as needed
        ]
        viewModel.connectedPeripheral = viewModel.peripherals[0]
        return viewModel
    }
}
