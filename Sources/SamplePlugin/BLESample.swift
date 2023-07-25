import Foundation
import CoreBluetooth

public class BLESample: NSObject, CBCentralManagerDelegate {
    var centralManager: CBCentralManager!
    var serviceUUID: CBUUID!
    var peripheral: CBPeripheral!
    
    public override init() {
        super.init()
        // queueはnilの場合はメインスレッドで実行される
        // https://developer.apple.com/documentation/corebluetooth/cbcentralmanager/1519001-init
        centralManager = CBCentralManager(delegate: self, queue: nil)
        serviceUUID = CBUUID(string: "068c47b7-fc04-4d47-975a-7952be1a576f")
    }
    
    public func scan() {
        if centralManager.state != .poweredOn {
            print("Bluetooth is not powered on.")
            return
        }
        
        if centralManager.isScanning {
            print("Already scanning.")
            return
        }
        
        let options: [String: Any] = [
            CBCentralManagerScanOptionAllowDuplicatesKey: false
        ]
        
        // serviceUUIDを指定すると、指定したサービスを持つペリフェラルのみをスキャンする。(推奨設定)
        // https://developer.apple.com/documentation/corebluetooth/cbcentralmanager/1518986-scanforperipherals
        centralManager.scanForPeripherals(withServices: [serviceUUID], options: options)
    }

    public func isConnected() -> Bool {
        if peripheral == nil {
            return false
        }
        return peripheral.state == .connected
    }
    
    func cbManagerStateName(_ state: CBManagerState) -> String {
        switch state {
        case .unknown:
            return "unknown"
        case .resetting:
            return "resetting"
        case .unsupported:
            return "unsupported"
        case .unauthorized:
            return "unauthorized"
        case .poweredOff:
            return "poweredOff"
        case .poweredOn:
            return "poweredOn"
        @unknown default:
            return "unknown default"
        }
    }
    
    // MARK: - CBCentralManagerDelegate
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("centralManagerDidUpdateState: \(cbManagerStateName(central.state))")
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        print("Device found: \(peripheral)")
        self.peripheral = peripheral
        central.stopScan()
        // optionsは特に指定しないといけなそうなものがなかったため、nilを指定している
        // https://developer.apple.com/documentation/corebluetooth/cbcentralmanager/1518766-connect
        central.connect(peripheral)
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("centralManager:didConnect: \(peripheral)")
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("centralManager:didFailToConnect: \(peripheral)")
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("centralManager:didDisconnectPeripheral: \(peripheral)")
    }
}
