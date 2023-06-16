import Foundation
import HealthKit

public class HealthKitData {
    public init() {}

    // HealthKitのデータにアクセスするためにユーザーの許可を求める。
    // 複数回呼び出しても構わない。(すでに許可済みの場合にはcompletionでtrueが渡される)
    public func authorize(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("is not health data available")
            completion(false)
            return
        }

        let typesToRead = Set([HKObjectType.quantityType(forIdentifier: .stepCount)!])

        HKHealthStore().requestAuthorization(toShare: nil, read: typesToRead) { (success, error) in
            if let error {
                print("requestAuthorization failed. error: \(error.localizedDescription)")
                completion(false)
                return
            }
            // successはリクエストが成功したかどうか。
            // ユーザーが許可したことを示す値ではない。
            completion(success)
        }
    }

    public func getStepsToday(completion: @escaping (Int) -> Void) {
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let type = HKSampleType.quantityType(forIdentifier: .stepCount)!
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now)
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { (query, statistics, error) in
            // The results come back on an anonymous background queue.
            DispatchQueue.main.async {
                guard let statistics else {
                    print("getStepsToday failed. error: \(error?.localizedDescription ?? "nil")")
                    completion(0)
                    return
                }

                let sum = statistics.sumQuantity()
                let steps = sum?.doubleValue(for: HKUnit.count())
                completion(Int(steps ?? 0))
            }
        }
        HKHealthStore().execute(query)
    }
}
