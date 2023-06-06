import Foundation

@_cdecl("sample_plugin_helloworld")
public func sample_plugin_helloworld() -> Int32 {
    print("Hello World!")
    return 3
}
