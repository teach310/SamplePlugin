import Foundation
import CoreBluetooth

// This is a wrapper class for exposing CBCentralManager to Unity.
public class CB4UCentralManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    private var peripherals: Dictionary<String, CBPeripheral> = [:]

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
    var didUpdateRSSIHandler: CB4UPeripheralDidUpdateRSSIHandler?
    var didReadRSSIHandler: CB4UPeripheralDidReadRSSIHandler?
    
    public override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func selfPointer() -> UnsafeMutableRawPointer {
        return Unmanaged.passUnretained(self).toOpaque()
    }

    public func retrievePeripherals(withIdentifiers identifiers: [UUID], _ sb: UnsafeMutablePointer<CChar>, _ sbSize: Int) -> Int32 {
        let foundPeripherals = centralManager.retrievePeripherals(withIdentifiers: identifiers)
        let foundPeripheralsCount = foundPeripherals.count
        if foundPeripheralsCount == 0 {
            return -1
        }

        let commaSeparatedPeripheralIds = foundPeripherals.map { $0.identifier.uuidString }.joined(separator: ",")
        let commaSeparatedPeripheralIdsLength = commaSeparatedPeripheralIds.utf8.count
        if commaSeparatedPeripheralIdsLength + 1 > sbSize {
            return -1
        }

        for peripheral in foundPeripherals {
            peripherals[peripheral.identifier.uuidString] = peripheral
        }

        _ = commaSeparatedPeripheralIds.withCString { (uuidCString) in
            strcpy(sb, uuidCString)
        }

        return 0
    }

    public func peripheralName(_ peripheralId: String, _ sb: UnsafeMutablePointer<CChar>, _ sbSize: Int) -> Int32 {
        guard let peripheral = peripherals[peripheralId] else {
            return -1
        }
        guard let peripheralName = peripheral.name else {
            return -1
        }
        let peripheralNameLength = peripheralName.utf8.count
        if peripheralNameLength + 1 > sbSize {
            return -1
        }
        _ = peripheralName.withCString { (nameCString) in
            strcpy(sb, nameCString)
        }
        return 0
    }

    public func peripheralState(_ peripheralId: String) -> Int32 {
        guard let peripheral = peripherals[peripheralId] else {
            return -1
        }
        return Int32(peripheral.state.rawValue)
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
            return -1
        }
        centralManager.connect(peripheral)
        return 0
    }

    public func cancelPeripheralConnection(_ peripheralId: String) -> Int32 {
        guard let peripheral = peripherals[peripheralId] else {
            return -1
        }
        centralManager.cancelPeripheralConnection(peripheral)
        return 0
    }

    public func characteristicProperties(_ peripheralId: String, _ serviceId: String, _ characteristicId: String) -> Int32 {
        guard let peripheral = peripherals[peripheralId] else {
            return -1
        }
        guard let service = peripheral.services?.first(where: { $0.uuid.uuidString == serviceId }) else {
            return -1
        }
        guard let characteristic = service.characteristics?.first(where: { $0.uuid.uuidString == characteristicId }) else {
            return -1
        }
        return Int32(characteristic.properties.rawValue)
    }

    public func discoverServices(_ peripheralId: String, _ serviceUUIDs: [CBUUID]?) -> Int32 {
        guard let peripheral = peripherals[peripheralId] else {
            return -1
        }
        peripheral.discoverServices(serviceUUIDs)
        return 0
    }

    public func discoverCharacteristics(_ peripheralId: String, _ serviceUUID: CBUUID, _ characteristicUUIDs: [CBUUID]?) -> Int32 {
        guard let peripheral = peripherals[peripheralId] else {
            return -1
        }
        guard let service = peripheral.services?.first(where: { $0.uuid == serviceUUID }) else {
            return -1
        }
        peripheral.discoverCharacteristics(characteristicUUIDs, for: service)
        return 0
    }

    public func readValue(_ peripheralId: String, _ serviceUUID: CBUUID, _ characteristicUUID: CBUUID) -> Int32 {
        guard let peripheral = peripherals[peripheralId] else {
            return -1
        }
        guard let service = peripheral.services?.first(where: { $0.uuid == serviceUUID }) else {
            return -1
        }
        guard let characteristic = service.characteristics?.first(where: { $0.uuid == characteristicUUID }) else {
            return -1
        }
        peripheral.readValue(for: characteristic)
        return 0
    }

    public func writeValue(_ peripheralId: String, _ serviceUUID: CBUUID, _ characteristicUUID: CBUUID, _ data: Data, _ type: CBCharacteristicWriteType) -> Int32 {
        guard let peripheral = peripherals[peripheralId] else {
            return -1
        }
        guard let service = peripheral.services?.first(where: { $0.uuid == serviceUUID }) else {
            return -1
        }
        guard let characteristic = service.characteristics?.first(where: { $0.uuid == characteristicUUID }) else {
            return -1
        }
        
        peripheral.writeValue(data, for: characteristic, type: type)
        return 0
    }

    public func setNotifyValue(_ peripheralId: String, _ serviceUUID: CBUUID, _ characteristicUUID: CBUUID, _ enabled: Bool) -> Int32 {
        guard let peripheral = peripherals[peripheralId] else {
            return -1
        }
        guard let service = peripheral.services?.first(where: { $0.uuid == serviceUUID }) else {
            return -1
        }
        guard let characteristic = service.characteristics?.first(where: { $0.uuid == characteristicUUID }) else {
            return -1
        }
        peripheral.setNotifyValue(enabled, for: characteristic)
        return 0
    }

    public func readRSSI(_ peripheralId: String) -> Int32 {
        guard let peripheral = peripherals[peripheralId] else {
            return -1
        }
        peripheral.readRSSI()
        return 0
    }

    // MARK: - CBCentralManagerDelegate
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        didUpdateStateHandler?(selfPointer(), Int32(central.state.rawValue))
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

    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        let peripheralId = peripheral.identifier.uuidString
        peripheralId.withCString { (uuidCString) in
            didConnectPeripheralHandler?(selfPointer(), uuidCString)
        }
    }

    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        let peripheralId = peripheral.identifier.uuidString
        peripheralId.withCString { (uuidCString) in
            didFailToConnectPeripheralHandler?(selfPointer(), uuidCString, errorToCode(error))
        }
    }

    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        let peripheralId = peripheral.identifier.uuidString
        peripheralId.withCString { (uuidCString) in
            didDisconnectPeripheralHandler?(selfPointer(), uuidCString, errorToCode(error))
        }
    }

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

    public func peripheralDidUpdateRSSI(_ peripheral: CBPeripheral, error: Error?) {
        let peripheralId = peripheral.identifier.uuidString

        peripheralId.withCString { (peripheralIdCString) in
            didUpdateRSSIHandler?(selfPointer(), peripheralIdCString, errorToCode(error))
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        let peripheralId = peripheral.identifier.uuidString

        peripheralId.withCString { (peripheralIdCString) in
            didReadRSSIHandler?(selfPointer(), peripheralIdCString, Int32(RSSI.intValue), errorToCode(error))
        }
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
}
