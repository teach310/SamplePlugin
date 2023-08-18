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

@_cdecl("cb4u_central_manager_register_handlers")
public func cb4u_central_manager_register_handlers(
    _ centralPtr: UnsafeRawPointer,
    _ didUpdateStateHandler: @escaping CB4UCentralManagerDidUpdateStateHandler,
    _ didDiscoverPeripheralHandler: @escaping CB4UCentralManagerDidDiscoverPeripheralHandler,
    _ didConnectPeripheralHandler: @escaping CB4UCentralManagerDidConnectPeripheralHandler,
    _ didFailToConnectPeripheralHandler: @escaping CB4UCentralManagerDidFailToConnectPeripheralHandler,
    _ didDisconnectPeripheralHandler: @escaping CB4UCentralManagerDidDisconnectPeripheralHandler,
    _ didDiscoverServicesHandler: @escaping CB4UPeripheralDidDiscoverServicesHandler,
    _ didDiscoverCharacteristicsHandler: @escaping CB4UPeripheralDidDiscoverCharacteristicsHandler
) {
    let instance = Unmanaged<CB4UCentralManager>.fromOpaque(centralPtr).takeUnretainedValue()
    
    instance.didUpdateStateHandler = didUpdateStateHandler
    instance.didDiscoverPeripheralHandler = didDiscoverPeripheralHandler
    instance.didConnectPeripheralHandler = didConnectPeripheralHandler
    instance.didFailToConnectPeripheralHandler = didFailToConnectPeripheralHandler
    instance.didDisconnectPeripheralHandler = didDisconnectPeripheralHandler
    instance.didDiscoverServicesHandler = didDiscoverServicesHandler
    instance.didDiscoverCharacteristicsHandler = didDiscoverCharacteristicsHandler
}

@_cdecl("cb4u_central_manager_scan_for_peripherals")
public func cb4u_central_manager_scan_for_peripherals(_ centralPtr: UnsafeRawPointer, _ serviceUUIDs: UnsafePointer<UnsafePointer<CChar>?>, _ serviceUUIDsCount: Int32) {
    let instance = Unmanaged<CB4UCentralManager>.fromOpaque(centralPtr).takeUnretainedValue()
    
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