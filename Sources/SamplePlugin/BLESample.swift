import Foundation
import CoreBluetooth

public class BLESample: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    var serviceUUID: CBUUID!
    var characteristicUUID: CBUUID!
    var peripheral: CBPeripheral!
    var remoteCharacteristic: CBCharacteristic!
    
    public override init() {
        super.init()
        // queueはnilの場合はメインスレッドで実行される
        // https://developer.apple.com/documentation/corebluetooth/cbcentralmanager/1519001-init
        centralManager = CBCentralManager(delegate: self, queue: nil)
        serviceUUID = CBUUID(string: "068c47b7-fc04-4d47-975a-7952be1a576f")
        characteristicUUID = CBUUID(string: "e3737b3f-a08d-405b-b32d-35a8f6c64c5d")
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

    public func writeData() {
        if peripheral == nil {
            print("peripheral is nil")
            return
        }

        guard let characteristic = remoteCharacteristic else {
            print("characteristic is nil")
            return
        }

        // ランダムな三桁の数値の文字列を書き込む
        let value = "Write Data " + String(format: "%03d", Int.random(in: 100..<1000))
        // type はwithResponseである必要はないが、取れるようにしておく
        // https://developer.apple.com/documentation/corebluetooth/cbperipheral/1518747-writevalue
        peripheral.writeValue(value.data(using: .utf8)!, for: characteristic, type: .withResponse)
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
        self.peripheral.delegate = self
        central.stopScan()
        // optionsは特に指定しないといけなそうなものがなかったため、nilを指定している
        // https://developer.apple.com/documentation/corebluetooth/cbcentralmanager/1518766-connect
        central.connect(peripheral)
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("centralManager:didConnect: \(peripheral)")
        
        peripheral.discoverServices([serviceUUID])
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("centralManager:didFailToConnect: \(peripheral)")
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("centralManager:didDisconnectPeripheral: \(peripheral)")
    }
    
    // MARK: - CBPeripheralDelegate
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        let services = peripheral.services ?? []
        print("peripheral:didDiscoverServices: \(services)")
        if let error = error {
            print("error: \(error)")
            return
        }
        
        for service in services {
            peripheral.discoverCharacteristics([characteristicUUID], for: service)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        let characteristics = service.characteristics ?? []
        print("peripheral:didDiscoverCharacteristicsFor: \(characteristics)")
        if let error = error {
            print("error: \(error)")
            return
        }

        self.remoteCharacteristic = characteristics.first { $0.uuid == characteristicUUID }
        
        for characteristic in characteristics {
            if characteristic.properties.contains(.read) {
                peripheral.readValue(for: characteristic)
            }
        }
    }
    
    // セントラルのread, ペリフェラルのnotifyによりvalueが更新されたときに呼ばれる
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("peripheral:didUpdateValueFor: \(characteristic)")
        if let error = error {
            print("error: \(error)")
            return
        }
        
        if let data = characteristic.value {
            print("data: \(data)")
            print("string: \(String(data: data, encoding: .utf8) ?? "")")
        }
    }

    // writeValue を .withResponse で実行した場合に呼ばれる
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("peripheral:didWriteValueFor: \(characteristic)")
        if let error = error {
            print("error: \(error)")
            return
        }
    }
}
