import CoreBluetooth

protocol PeripheralProtocol {
    var identifier: UUID { get }
    var name: String? { get }
    func writeValue(_ data: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType)
    // Add other properties and methods you need from CBPeripheral

}

// Extend CBPeripheral to conform to this protocol
extension CBPeripheral: PeripheralProtocol {}

class MockPeripheral: PeripheralProtocol {
    var identifier: UUID
    var name: String?

    init(identifier: UUID, name: String?) {
        self.identifier = identifier
        self.name = name
    }
    // Mock implementation of writeValue
        func writeValue(_ data: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType) {
            // Implement mock behavior here
        }

    // Implement other properties and methods as needed
}
