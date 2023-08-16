import Foundation
import CoreBluetooth

// This is a wrapper class for exposing CBCentralManager to Unity.
public class CB4UCentralManager: NSObject, CBCentralManagerDelegate {
    private var centralManager: CBCentralManager!
    private var peripherals: Dictionary<String, CBPeripheral> = [:]

    var didUpdateStateHandler: CB4UCentralManagerDidUpdateStateHandler?
    var didDiscoverPeripheralHandler: CB4UCentralManagerDidDiscoverPeripheralHandler?
    var didConnectPeripheralHandler: CB4UCentralManagerDidConnectPeripheralHandler?
    var didFailToConnectPeripheralHandler: CB4UCentralManagerDidFailToConnectPeripheralHandler?
    var didDisconnectPeripheralHandler: CB4UCentralManagerDidDisconnectPeripheralHandler?
    
    public override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func selfPointer() -> UnsafeMutableRawPointer {
        return Unmanaged.passUnretained(self).toOpaque()
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

    // MARK: - CBCentralManagerDelegate
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        didUpdateStateHandler?(selfPointer(), Int32(central.state.rawValue))
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let peripheralId = peripheral.identifier.uuidString
        peripherals[peripheralId] = peripheral
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
