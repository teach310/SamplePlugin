import CoreBluetooth

extension CB4UCentralManager {
    func delegatePeripheral(_ peripheralId: String, _ action: (CBPeripheral) -> Int32) -> Int32 {
        guard let peripheral = peripherals[peripheralId] else {
            return peripheralNotFound
        }
        return action(peripheral)
    }
    
    func delegatePeripheral(_ peripheralId: String, _ action: (CBPeripheral) -> Void) -> Int32 {
        return delegatePeripheral(peripheralId) { (peripheral) -> Int32 in
            action(peripheral)
            return success
        }
    }
    
    func delegatePeripheralForCharacteristic(_ peripheralId: String, _ serviceUUID: CBUUID, _ characteristicUUID: CBUUID, _ action: (CBPeripheral, CBCharacteristic) -> Void) -> Int32 {
        guard let peripheral = peripherals[peripheralId] else {
            return peripheralNotFound
        }
        guard let service = peripheral.services?.first(where: { $0.uuid == serviceUUID }) else {
            return serviceNotFound
        }
        guard let characteristic = service.characteristics?.first(where: { $0.uuid == characteristicUUID }) else {
            return characteristicNotFound
        }
        action(peripheral, characteristic)
        
        return success
    }
    
    public func peripheralName(_ peripheralId: String, _ sb: UnsafeMutablePointer<CChar>, _ sbSize: Int) -> Int32 {
        return delegatePeripheral(peripheralId) { (peripheral) -> Int32 in
            guard let peripheralName = peripheral.name else {
                return failure
            }
            let peripheralNameLength = peripheralName.utf8.count
            if peripheralNameLength + 1 > sbSize {
                return failure
            }
            _ = peripheralName.withCString { (nameCString) in
                strcpy(sb, nameCString)
            }
            return success
        }
    }
    
    public func peripheralState(_ peripheralId: String) -> Int32 {
        return delegatePeripheral(peripheralId) { (peripheral) -> Int32 in
            return Int32(peripheral.state.rawValue)
        }
    }
    
    public func discoverServices(_ peripheralId: String, _ serviceUUIDs: [CBUUID]?) -> Int32 {
        return delegatePeripheral(peripheralId) { (peripheral) -> Void in
            peripheral.discoverServices(serviceUUIDs)
        }
    }
    
    public func discoverCharacteristics(_ peripheralId: String, _ serviceUUID: CBUUID, _ characteristicUUIDs: [CBUUID]?) -> Int32 {
        guard let peripheral = peripherals[peripheralId] else {
            return peripheralNotFound
        }
        guard let service = peripheral.services?.first(where: { $0.uuid == serviceUUID }) else {
            return serviceNotFound
        }
        peripheral.discoverCharacteristics(characteristicUUIDs, for: service)
        return success
    }
    
    public func readValue(_ peripheralId: String, _ serviceUUID: CBUUID, _ characteristicUUID: CBUUID) -> Int32 {
        return delegatePeripheralForCharacteristic(peripheralId, serviceUUID, characteristicUUID) { (peripheral, characteristic) -> Void in
            peripheral.readValue(for: characteristic)
        }
    }
    
    public func writeValue(_ peripheralId: String, _ serviceUUID: CBUUID, _ characteristicUUID: CBUUID, _ data: Data, _ type: CBCharacteristicWriteType) -> Int32 {
        return delegatePeripheralForCharacteristic(peripheralId, serviceUUID, characteristicUUID) { (peripheral, characteristic) -> Void in
            peripheral.writeValue(data, for: characteristic, type: type)
        }
    }
    
    public func setNotifyValue(_ peripheralId: String, _ serviceUUID: CBUUID, _ characteristicUUID: CBUUID, _ enabled: Bool) -> Int32 {
        return delegatePeripheralForCharacteristic(peripheralId, serviceUUID, characteristicUUID) { (peripheral, characteristic) -> Void in
            peripheral.setNotifyValue(enabled, for: characteristic)
        }
    }
    
    public func readRSSI(_ peripheralId: String) -> Int32 {
        return delegatePeripheral(peripheralId) { (peripheral) -> Void in
            peripheral.readRSSI()
        }
    }
}
