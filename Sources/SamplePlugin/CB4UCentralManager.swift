import Foundation
import CoreBluetooth

// This is a wrapper class for exposing CBCentralManager to Unity.
public class CB4UCentralManager: NSObject {
    private var centralManager: CBCentralManager!
    var peripherals: Dictionary<String, CBPeripheral> = [:]
    
    var didUpdateStateHandler: CB4UCentralManagerDidUpdateStateHandler?
    var didDiscoverPeripheralHandler: CB4UCentralManagerDidDiscoverPeripheralHandler?
    var didConnectPeripheralHandler: CB4UCentralManagerDidConnectPeripheralHandler?
    var didFailToConnectPeripheralHandler: CB4UCentralManagerDidFailToConnectPeripheralHandler?
    var didDisconnectPeripheralHandler: CB4UCentralManagerDidDisconnectPeripheralHandler?
    
    var didDiscoverServicesHandler: CB4UPeripheralDidDiscoverServicesHandler?
    var didDiscoverCharacteristicsHandler: CB4UPeripheralDidDiscoverCharacteristicsHandler?
    var didUpdateValueForCharacteristicHandler: CB4UPeripheralDidUpdateValueForCharacteristicHandler?
    var didWriteValueForCharacteristicHandler: CB4UPeripheralDidWriteValueForCharacteristicHandler?
    var didUpdateNotificationStateForCharacteristicHandler: CB4UPeripheralDidUpdateNotificationStateForCharacteristicHandler?
    var didReadRSSIHandler: CB4UPeripheralDidReadRSSIHandler?
    
    let peripheralNotFound: Int32 = -1
    let serviceNotFound: Int32 = -1
    let characteristicNotFound: Int32 = -1
    let failure: Int32 = -1 // unprocessable error
    let success: Int32 = 0
    
    public override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func selfPointer() -> UnsafeMutableRawPointer {
        return Unmanaged.passUnretained(self).toOpaque()
    }
    
    // NOTE: code 0 is unknown error. so if error is nil, return -1.
    func errorToCode(_ error: Error?) -> Int32 {
        if error == nil {
            return -1
        }
        
        if let error = error as? CBError {
            return Int32(error.errorCode)
        }
        
        return Int32(error!._code)
    }
    
    public func retrievePeripherals(withIdentifiers identifiers: [UUID], _ sb: UnsafeMutablePointer<CChar>, _ sbSize: Int) -> Int32 {
        let foundPeripherals = centralManager.retrievePeripherals(withIdentifiers: identifiers)
        let foundPeripheralsCount = foundPeripherals.count
        if foundPeripheralsCount == 0 {
            return failure
        }
        
        let commaSeparatedPeripheralIds = foundPeripherals.map { $0.identifier.uuidString }.joined(separator: ",")
        let commaSeparatedPeripheralIdsLength = commaSeparatedPeripheralIds.utf8.count
        if commaSeparatedPeripheralIdsLength + 1 > sbSize {
            return failure
        }
        
        for peripheral in foundPeripherals {
            peripherals[peripheral.identifier.uuidString] = peripheral
        }
        
        _ = commaSeparatedPeripheralIds.withCString { (uuidCString) in
            strcpy(sb, uuidCString)
        }
        
        return success
    }
    
    // MARK: - Scanning or Stopping Scans of Peripherals
    
    // TODO: options argument is not supported yet.
    public func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?) {
        let options: [String: Any] = [
            CBCentralManagerScanOptionAllowDuplicatesKey: false
        ]
        
        centralManager.scanForPeripherals(withServices: serviceUUIDs, options: options)
    }
    
    public func stopScan() {
        centralManager.stopScan()
    }
    
    public var isScanning: Bool {
        return centralManager.isScanning
    }
    
    // MARK: Establishing or Canceling Connections with Peripherals
    
    public func connect(_ peripheralId: String) -> Int32 {
        guard let peripheral = peripherals[peripheralId] else {
            return peripheralNotFound
        }
        centralManager.connect(peripheral)
        return success
    }
    
    public func cancelPeripheralConnection(_ peripheralId: String) -> Int32 {
        guard let peripheral = peripherals[peripheralId] else {
            return peripheralNotFound
        }
        centralManager.cancelPeripheralConnection(peripheral)
        return success
    }
}

extension CB4UCentralManager: CBCentralManagerDelegate {
    
    // MARK: - CBCentralManagerDelegate
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        didUpdateStateHandler?(selfPointer(), Int32(central.state.rawValue))
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        let peripheralId = peripheral.identifier.uuidString
        peripheralId.withCString { (uuidCString) in
            didConnectPeripheralHandler?(selfPointer(), uuidCString)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        let peripheralId = peripheral.identifier.uuidString
        peripheralId.withCString { (uuidCString) in
            didDisconnectPeripheralHandler?(selfPointer(), uuidCString, errorToCode(error))
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        let peripheralId = peripheral.identifier.uuidString
        peripheralId.withCString { (uuidCString) in
            didFailToConnectPeripheralHandler?(selfPointer(), uuidCString, errorToCode(error))
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let peripheralId = peripheral.identifier.uuidString
        peripherals[peripheralId] = peripheral
        peripheral.delegate = self
        peripheralId.withCString { (uuidCString) in
            (peripheral.name ?? "").withCString { (nameCString) in
                didDiscoverPeripheralHandler?(selfPointer(), uuidCString, nameCString)
            }
        }
    }
}

extension CB4UCentralManager: CBPeripheralDelegate {
    // MARK: - CBPeripheralDelegate
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        let peripheralId = peripheral.identifier.uuidString
        let commaSeparatedServiceIds = peripheral.services?.map { $0.uuid.uuidString }.joined(separator: ",") ?? ""
        
        peripheralId.withCString { (peripheralIdCString) in
            commaSeparatedServiceIds.withCString { (commaSeparatedServiceIdsCString) in
                didDiscoverServicesHandler?(selfPointer(), peripheralIdCString, commaSeparatedServiceIdsCString, errorToCode(error))
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        let peripheralId = peripheral.identifier.uuidString
        let serviceId = service.uuid.uuidString
        let commaSeparatedCharacteristicIds = service.characteristics?.map { $0.uuid.uuidString }.joined(separator: ",") ?? ""
        
        peripheralId.withCString { (peripheralIdCString) in
            serviceId.withCString { (serviceIdCString) in
                commaSeparatedCharacteristicIds.withCString { (commaSeparatedCharacteristicIdsCString) in
                    didDiscoverCharacteristicsHandler?(selfPointer(), peripheralIdCString, serviceIdCString, commaSeparatedCharacteristicIdsCString, errorToCode(error))
                }
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let peripheralId = peripheral.identifier.uuidString
        let serviceId = characteristic.service?.uuid.uuidString ?? ""
        let characteristicId = characteristic.uuid.uuidString
        let value = characteristic.value ?? Data()
        
        peripheralId.withCString { (peripheralIdCString) in
            serviceId.withCString { (serviceIdCString) in
                characteristicId.withCString { (characteristicIdCString) in
                    value.withUnsafeBytes { (valueBytes: UnsafeRawBufferPointer) in
                        let bytes = valueBytes.bindMemory(to: UInt8.self).baseAddress!
                        didUpdateValueForCharacteristicHandler?(selfPointer(), peripheralIdCString, serviceIdCString, characteristicIdCString, bytes, Int32(value.count), errorToCode(error))
                    }
                }
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        let peripheralId = peripheral.identifier.uuidString
        let serviceId = characteristic.service?.uuid.uuidString ?? ""
        let characteristicId = characteristic.uuid.uuidString
        
        peripheralId.withCString { (peripheralIdCString) in
            serviceId.withCString { (serviceIdCString) in
                characteristicId.withCString { (characteristicIdCString) in
                    didWriteValueForCharacteristicHandler?(selfPointer(), peripheralIdCString, serviceIdCString, characteristicIdCString, errorToCode(error))
                }
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        let peripheralId = peripheral.identifier.uuidString
        let serviceId = characteristic.service?.uuid.uuidString ?? ""
        let characteristicId = characteristic.uuid.uuidString
        
        let notificationState = characteristic.isNotifying ? 1 : 0
        peripheralId.withCString { (peripheralIdCString) in
            serviceId.withCString { (serviceIdCString) in
                characteristicId.withCString { (characteristicIdCString) in
                    didUpdateNotificationStateForCharacteristicHandler?(selfPointer(), peripheralIdCString, serviceIdCString, characteristicIdCString, Int32(notificationState), errorToCode(error))
                }
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        let peripheralId = peripheral.identifier.uuidString
        
        peripheralId.withCString { (peripheralIdCString) in
            didReadRSSIHandler?(selfPointer(), peripheralIdCString, Int32(RSSI.intValue), errorToCode(error))
        }
    }
}
