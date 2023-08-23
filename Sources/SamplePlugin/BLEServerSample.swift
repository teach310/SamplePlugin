import Foundation
import CoreBluetooth

public class BLEServerSample: NSObject, CBPeripheralManagerDelegate {
    var peripheralManager: CBPeripheralManager!
    var serviceUUID: CBUUID!
    var characteristicUUID: CBUUID!
    var notifyCharacteristicUUID: CBUUID!

    var characteristic: CBMutableCharacteristic?
    var notifyCharacteristic: CBMutableCharacteristic?

    public override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        serviceUUID = CBUUID(string: "068C47B7-FC04-4D47-975A-7952BE1A576F")
        characteristicUUID = CBUUID(string: "E3737B3F-A08D-405B-B32D-35A8F6C64C5D")
        notifyCharacteristicUUID = CBUUID(string: "C9DA2CE8-D119-40D5-90F7-EF24627E8193")
    }

    public func onClick() {
        writeData()
    }

    func writeData() {
        guard let peripheralManager = peripheralManager,
              let notifyCharacteristic = notifyCharacteristic else {
            return
        }

        // ランダムな三桁の数値の文字列を書き込む
        let value = "Notify Data " + String(format: "%03d", Int.random(in: 100..<1000))
        peripheralManager.updateValue(
            value.data(using: .utf8)!,
            for: notifyCharacteristic,
            onSubscribedCentrals: nil
        )
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

    // MARK: - CBPeripheralManagerDelegate

    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("peripheralManagerDidUpdateState: \(cbManagerStateName(peripheral.state))")

        if peripheral.state == .poweredOn {
            let service = CBMutableService(type: serviceUUID, primary: true)
            // 参考
            // https://toio.github.io/toio-spec/docs/2.1.0/ble_configuration
            characteristic = CBMutableCharacteristic(
                type: characteristicUUID,
                properties: [.read, .write, .notify],
                value: nil,
                permissions: [.readable, .writeable]
            )

            notifyCharacteristic = CBMutableCharacteristic(
                type: notifyCharacteristicUUID,
                properties: [.notify],
                value: nil,
                permissions: [.readable]
            )

            // Descriptorは必須ではなさそうなため省略

            service.characteristics = [characteristic!, notifyCharacteristic!]
            peripheral.add(service)
        }
    }

    public func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        print("didAdd service: \(service.uuid.uuidString)")

        if let error = error {
            print("error: \(error.localizedDescription)")
            return
        }

        let advertisementData = [CBAdvertisementDataServiceUUIDsKey: [serviceUUID]]
        peripheral.startAdvertising(advertisementData)
    }

    public func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        print("peripheralManagerDidStartAdvertising")

        if let error = error {
            print("error: \(error.localizedDescription)")
            return
        }
    }

    public func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("didSubscribeTo characteristic: \(characteristic.uuid.uuidString)")

        if !characteristic.uuid.isEqual(notifyCharacteristicUUID) {
            return
        }

        peripheral.stopAdvertising()
    }

    public func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        print("didReceiveRead request: \(request)")

        if !request.characteristic.uuid.isEqual(characteristicUUID) {
            peripheral.respond(to: request, withResult: .attributeNotFound)
            return
        }

        if request.offset > characteristicUUID.data.count {
            peripheral.respond(to: request, withResult: .invalidOffset)
            return
        }

        let data = "Hello, World!".data(using: .utf8)
        request.value = data
        peripheral.respond(to: request, withResult: .success)
    }

    public func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        print("didReceiveWrite requests: \(requests)")

        for request in requests {
            if !request.characteristic.uuid.isEqual(characteristicUUID) {
                peripheral.respond(to: request, withResult: .attributeNotFound)
                return
            }

            if request.offset > characteristicUUID.data.count {
                peripheral.respond(to: request, withResult: .invalidOffset)
                return
            }

            if let data = request.value {
                print("data: \(String(data: data, encoding: .utf8) ?? "")")

                // characteristic でnotify
                peripheralManager.updateValue(
                    data,
                    for: characteristic!,
                    onSubscribedCentrals: nil
                )
            }

            peripheral.respond(to: request, withResult: .success)
        }
    }

    // 接続が切れた時にも呼ばれる    
    public func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        print("didUnsubscribeFrom characteristic: \(characteristic.uuid.uuidString)")

        if !characteristic.uuid.isEqual(notifyCharacteristicUUID) {
            return
        }

        peripheral.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [serviceUUID]])
    }

    public func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        print("peripheralManagerIsReady")
    }
}
