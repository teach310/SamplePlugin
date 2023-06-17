import Foundation

@_cdecl("sample_plugin_helloworld")
public func sample_plugin_helloworld() -> Int32 {
    print("Hello World!")
    return 3
}

#if os(iOS)
public typealias SamplePluginAuthorizeCompletion = @convention(c) (Bool) -> Void

@_cdecl("sample_plugin_authorize")
public func sample_plugin_authorize(_ completion: @escaping SamplePluginAuthorizeCompletion) {
    HealthKitData().authorize(completion: completion)
}

public typealias SamplePluginGetStepsTodayCompletion = @convention(c) (Int32) -> Void

@_cdecl("sample_plugin_get_steps_today")
public func sample_plugin_get_steps_today(_ completion: @escaping SamplePluginGetStepsTodayCompletion) {
    HealthKitData().getStepsToday { steps in
        completion(Int32(steps))
    }
}
#endif
