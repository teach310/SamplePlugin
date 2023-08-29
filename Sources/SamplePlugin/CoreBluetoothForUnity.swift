import Foundation
import CoreBluetooth

@_cdecl("cb4u_central_manager_new")
public func cb4u_central_manager_new() -> UnsafeMutableRawPointer {
    let instance = CB4UCentralManager()
    return Unmanaged.passRetained(instance).toOpaque()
}

@_cdecl("cb4u_central_manager_release")
public func cb4u_central_manager_release(_ centralPtr: UnsafeRawPointer) {
    Unmanaged<CB4UCentralManager>.fromOpaque(centralPtr).release()
}

public typealias CB4UCentralManagerDidUpdateStateHandler = @convention(c) (UnsafeRawPointer, Int32) -> Void
public typealias CB4UCentralManagerDidDiscoverPeripheralHandler = @convention(c) (UnsafeRawPointer, UnsafePointer<CChar>, UnsafePointer<CChar>) -> Void
public typealias CB4UCentralManagerDidConnectPeripheralHandler = @convention(c) (UnsafeRawPointer, UnsafePointer<CChar>) -> Void
public typealias CB4UCentralManagerDidFailToConnectPeripheralHandler = @convention(c) (UnsafeRawPointer, UnsafePointer<CChar>, Int32) -> Void
public typealias CB4UCentralManagerDidDisconnectPeripheralHandler = @convention(c) (UnsafeRawPointer, UnsafePointer<CChar>, Int32) -> Void

public typealias CB4UPeripheralDidDiscoverServicesHandler = @convention(c) (UnsafeRawPointer, UnsafePointer<CChar>, UnsafePointer<CChar>, Int32) -> Void
public typealias CB4UPeripheralDidDiscoverCharacteristicsHandler = @convention(c) (UnsafeRawPointer, UnsafePointer<CChar>, UnsafePointer<CChar>, UnsafePointer<CChar>, Int32) -> Void
public typealias CB4UPeripheralDidUpdateValueForCharacteristicHandler = @convention(c) (UnsafeRawPointer, UnsafePointer<CChar>, UnsafePointer<CChar>, UnsafePointer<CChar>, UnsafePointer<UInt8>, Int32, Int32) -> Void
public typealias CB4UPeripheralDidWriteValueForCharacteristicHandler = @convention(c) (UnsafeRawPointer, UnsafePointer<CChar>, UnsafePointer<CChar>, UnsafePointer<CChar>, Int32) -> Void
public typealias CB4UPeripheralDidUpdateNotificationStateForCharacteristicHandler = @convention(c) (UnsafeRawPointer, UnsafePointer<CChar>, UnsafePointer<CChar>, UnsafePointer<CChar>, Int32, Int32) -> Void
public typealias CB4UPeripheralDidUpdateRSSIHandler = @convention(c) (UnsafeRawPointer, UnsafePointer<CChar>, Int32) -> Void
public typealias CB4UPeripheralDidReadRSSIHandler = @convention(c) (UnsafeRawPointer, UnsafePointer<CChar>, Int32, Int32) -> Void

@_cdecl("cb4u_central_manager_register_handlers")
public func cb4u_central_manager_register_handlers(
    _ centralPtr: UnsafeRawPointer,
    _ didUpdateStateHandler: @escaping CB4UCentralManagerDidUpdateStateHandler,
    _ didDiscoverPeripheralHandler: @escaping CB4UCentralManagerDidDiscoverPeripheralHandler,
    _ didConnectPeripheralHandler: @escaping CB4UCentralManagerDidConnectPeripheralHandler,
    _ didFailToConnectPeripheralHandler: @escaping CB4UCentralManagerDidFailToConnectPeripheralHandler,
    _ didDisconnectPeripheralHandler: @escaping CB4UCentralManagerDidDisconnectPeripheralHandler,
    _ didDiscoverServicesHandler: @escaping CB4UPeripheralDidDiscoverServicesHandler,
    _ didDiscoverCharacteristicsHandler: @escaping CB4UPeripheralDidDiscoverCharacteristicsHandler,
    _ didUpdateValueForCharacteristicHandler: @escaping CB4UPeripheralDidUpdateValueForCharacteristicHandler,
    _ didWriteValueForCharacteristicHandler: @escaping CB4UPeripheralDidWriteValueForCharacteristicHandler,
    _ didUpdateNotificationStateForCharacteristicHandler: @escaping CB4UPeripheralDidUpdateNotificationStateForCharacteristicHandler,
    _ didUpdateRSSIHandler: @escaping CB4UPeripheralDidUpdateRSSIHandler,
    _ didReadRSSIHandler: @escaping CB4UPeripheralDidReadRSSIHandler
) {
    let instance = Unmanaged<CB4UCentralManager>.fromOpaque(centralPtr).takeUnretainedValue()
    
    instance.didUpdateStateHandler = didUpdateStateHandler
    instance.didDiscoverPeripheralHandler = didDiscoverPeripheralHandler
    instance.didConnectPeripheralHandler = didConnectPeripheralHandler
    instance.didFailToConnectPeripheralHandler = didFailToConnectPeripheralHandler
    instance.didDisconnectPeripheralHandler = didDisconnectPeripheralHandler
    instance.didDiscoverServicesHandler = didDiscoverServicesHandler
    instance.didDiscoverCharacteristicsHandler = didDiscoverCharacteristicsHandler
    instance.didUpdateValueForCharacteristicHandler = didUpdateValueForCharacteristicHandler
    instance.didWriteValueForCharacteristicHandler = didWriteValueForCharacteristicHandler
    instance.didUpdateNotificationStateForCharacteristicHandler = didUpdateNotificationStateForCharacteristicHandler
    instance.didUpdateRSSIHandler = didUpdateRSSIHandler
    instance.didReadRSSIHandler = didReadRSSIHandler
}

@_cdecl("cb4u_central_manager_retrieve_peripherals_with_identifiers")
public func cb4u_central_manager_retrieve_peripherals_with_identifiers(
    _ centralPtr: UnsafeRawPointer,
    _ peripheralIds: UnsafePointer<UnsafePointer<CChar>?>,
    _ peripheralIdsCount: Int32,
    _ sb: UnsafeMutablePointer<CChar>,
    _ sbSize: Int32
    ) -> Int32 {
    let instance = Unmanaged<CB4UCentralManager>.fromOpaque(centralPtr).takeUnretainedValue()
    
    let peripheralIdsArray = (0..<Int(peripheralIdsCount)).compactMap { index -> UUID? in
        let uuidString = String(cString: peripheralIds[index]!)
        guard let uuid = UUID(uuidString: uuidString) else {
            return nil
        }
        return uuid
    }
    // invalid peripheralIds
    if peripheralIdsArray.count != Int(peripheralIdsCount) {
        return -1
    }
    
    return instance.retrievePeripherals(withIdentifiers: peripheralIdsArray, sb, Int(sbSize))
}

@_cdecl("cb4u_central_manager_scan_for_peripherals")
public func cb4u_central_manager_scan_for_peripherals(_ centralPtr: UnsafeRawPointer, _ serviceUUIDs: UnsafePointer<UnsafePointer<CChar>?>, _ serviceUUIDsCount: Int32) {
    let instance = Unmanaged<CB4UCentralManager>.fromOpaque(centralPtr).takeUnretainedValue()
    
    // serviceIDがinvalidなときに-1を返したほうが良い。
    let serviceUUIDsArray = (0..<Int(serviceUUIDsCount)).map { index -> CBUUID in
        let uuidString = String(cString: serviceUUIDs[index]!)
        return CBUUID(string: uuidString)
    }
    
    instance.scanForPeripherals(withServices: serviceUUIDsArray)
}


@_cdecl("cb4u_central_manager_stop_scan")
public func cb4u_central_manager_stop_scan(_ centralPtr: UnsafeRawPointer) {
    let instance = Unmanaged<CB4UCentralManager>.fromOpaque(centralPtr).takeUnretainedValue()
    
    instance.stopScan()
}

@_cdecl("cb4u_central_manager_is_scanning")
public func cb4u_central_manager_is_scanning(_ centralPtr: UnsafeRawPointer) -> Bool {
    let instance = Unmanaged<CB4UCentralManager>.fromOpaque(centralPtr).takeUnretainedValue()
    
    return instance.isScanning
}

@_cdecl("cb4u_central_manager_connect_peripheral")
public func cb4u_central_manager_connect_peripheral(_ centralPtr: UnsafeRawPointer, _ peripheralId: UnsafePointer<CChar>) -> Int32 {
    let instance = Unmanaged<CB4UCentralManager>.fromOpaque(centralPtr).takeUnretainedValue()
    
    return instance.connect(String(cString: peripheralId))
}

@_cdecl("cb4u_central_manager_cancel_peripheral_connection")
public func cb4u_central_manager_cancel_peripheral_connection(_ centralPtr: UnsafeRawPointer, _ peripheralId: UnsafePointer<CChar>) -> Int32 {
    let instance = Unmanaged<CB4UCentralManager>.fromOpaque(centralPtr).takeUnretainedValue()
    
    return instance.cancelPeripheralConnection(String(cString: peripheralId))
}

@_cdecl("cb4u_central_manager_peripheral_name")
public func cb4u_central_manager_peripheral_name(_ centralPtr: UnsafeRawPointer, _ peripheralId: UnsafePointer<CChar>, _ sb: UnsafeMutablePointer<CChar>, _ sbSize: Int32) -> Int32 {
    let instance = Unmanaged<CB4UCentralManager>.fromOpaque(centralPtr).takeUnretainedValue()
    
    return instance.peripheralName(String(cString: peripheralId), sb, Int(sbSize))
}

@_cdecl("cb4u_central_manager_peripheral_state")
public func cb4u_central_manager_peripheral_state(_ centralPtr: UnsafeRawPointer, _ peripheralId: UnsafePointer<CChar>) -> Int32 {
    let instance = Unmanaged<CB4UCentralManager>.fromOpaque(centralPtr).takeUnretainedValue()
    
    return instance.peripheralState(String(cString: peripheralId))
}

@_cdecl("cb4u_central_manager_characteristic_properties")
public func cb4u_central_manager_characteristic_properties(_ centralPtr: UnsafeRawPointer, _ peripheralId: UnsafePointer<CChar>, _ serviceId: UnsafePointer<CChar>, _ characteristicId: UnsafePointer<CChar>) -> Int32 {
    let instance = Unmanaged<CB4UCentralManager>.fromOpaque(centralPtr).takeUnretainedValue()
    
    return instance.characteristicProperties(String(cString: peripheralId), String(cString: serviceId), String(cString: characteristicId))
}

@_cdecl("cb4u_peripheral_discover_services")
public func cb4u_peripheral_discover_services(_ centralPtr: UnsafeRawPointer, _ peripheralId: UnsafePointer<CChar>, _ serviceUUIDs: UnsafePointer<UnsafePointer<CChar>?>, _ serviceUUIDsCount: Int32) -> Int32 {
    let instance = Unmanaged<CB4UCentralManager>.fromOpaque(centralPtr).takeUnretainedValue()
    
    let serviceUUIDsArray = (0..<Int(serviceUUIDsCount)).map { index -> CBUUID in
        let uuidString = String(cString: serviceUUIDs[index]!)
        return CBUUID(string: uuidString)
    }
    
    return instance.discoverServices(String(cString: peripheralId), serviceUUIDsArray)
}

@_cdecl("cb4u_peripheral_discover_characteristics")
public func cb4u_peripheral_discover_characteristics(_ centralPtr: UnsafeRawPointer, _ peripheralId: UnsafePointer<CChar>, _ serviceId: UnsafePointer<CChar>, _ characteristicUUIDs: UnsafePointer<UnsafePointer<CChar>?>, _ characteristicUUIDsCount: Int32) -> Int32 {
    let instance = Unmanaged<CB4UCentralManager>.fromOpaque(centralPtr).takeUnretainedValue()
    let serviceUUID = CBUUID(string: String(cString: serviceId))
    
    let characteristicUUIDsArray = (0..<Int(characteristicUUIDsCount)).map { index -> CBUUID in
        let uuidString = String(cString: characteristicUUIDs[index]!)
        return CBUUID(string: uuidString)
    }
    
    return instance.discoverCharacteristics(String(cString: peripheralId), serviceUUID, characteristicUUIDsArray)
}

@_cdecl("cb4u_peripheral_read_value_for_characteristic")
public func cb4u_peripheral_read_value_for_characteristic(_ centralPtr: UnsafeRawPointer, _ peripheralId: UnsafePointer<CChar>, _ serviceId: UnsafePointer<CChar>, _ characteristicId: UnsafePointer<CChar>) -> Int32 {
    let instance = Unmanaged<CB4UCentralManager>.fromOpaque(centralPtr).takeUnretainedValue()
    let serviceUUID = CBUUID(string: String(cString: serviceId))
    let characteristicUUID = CBUUID(string: String(cString: characteristicId))
    
    return instance.readValue(String(cString: peripheralId), serviceUUID, characteristicUUID)
}

@_cdecl("cb4u_peripheral_write_value_for_characteristic")
public func cb4u_peripheral_write_value_for_characteristic(_ centralPtr: UnsafeRawPointer, _ peripheralId: UnsafePointer<CChar>, _ serviceId: UnsafePointer<CChar>, _ characteristicId: UnsafePointer<CChar>, _ dataBytes: UnsafePointer<UInt8>, _ dataLength: Int32, _ writeType: Int32) -> Int32 {
    let instance = Unmanaged<CB4UCentralManager>.fromOpaque(centralPtr).takeUnretainedValue()
    let serviceUUID = CBUUID(string: String(cString: serviceId))
    let characteristicUUID = CBUUID(string: String(cString: characteristicId))
    
    let data = Data(bytes: dataBytes, count: Int(dataLength))
    return instance.writeValue(String(cString: peripheralId), serviceUUID, characteristicUUID, data, CBCharacteristicWriteType(rawValue: Int(writeType))!)
}

@_cdecl("cb4u_peripheral_set_notify_value_for_characteristic")
public func cb4u_peripheral_set_notify_value_for_characteristic(_ centralPtr: UnsafeRawPointer, _ peripheralId: UnsafePointer<CChar>, _ serviceId: UnsafePointer<CChar>, _ characteristicId: UnsafePointer<CChar>, _ enabled: Bool) -> Int32 {
    let instance = Unmanaged<CB4UCentralManager>.fromOpaque(centralPtr).takeUnretainedValue()
    let serviceUUID = CBUUID(string: String(cString: serviceId))
    let characteristicUUID = CBUUID(string: String(cString: characteristicId))
    
    return instance.setNotifyValue(String(cString: peripheralId), serviceUUID, characteristicUUID, enabled)
}

@_cdecl("cb4u_central_manager_peripheral_read_rssi")
public func cb4u_central_manager_peripheral_read_rssi(_ centralPtr: UnsafeRawPointer, _ peripheralId: UnsafePointer<CChar>) -> Int32 {
    let instance = Unmanaged<CB4UCentralManager>.fromOpaque(centralPtr).takeUnretainedValue()
    
    return instance.readRSSI(String(cString: peripheralId))
}
