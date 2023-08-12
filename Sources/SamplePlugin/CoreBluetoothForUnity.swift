import Foundation

@_cdecl("cb4u_central_manager_new")
public func cb4u_central_manager_new() -> UnsafeMutableRawPointer {
    let instance = CB4UCentralManager()
    return Unmanaged.passRetained(instance).toOpaque()
}

@_cdecl("cb4u_central_manager_release")
public func cb4u_central_manager_release(_ instancePtr: UnsafeRawPointer) {
    Unmanaged<CB4UCentralManager>.fromOpaque(instancePtr).release()
}

public typealias CB4UCentralManagerDidUpdateStateHandler = @convention(c) (UnsafeRawPointer, Int32) -> Void

@_cdecl("cb4u_central_manager_register_handlers")
public func cb4u_central_manager_register_handlers(
    _ instancePtr: UnsafeRawPointer,
    _ didUpdateStateHandler: @escaping CB4UCentralManagerDidUpdateStateHandler
) {
    let instance = Unmanaged<CB4UCentralManager>.fromOpaque(instancePtr).takeUnretainedValue()
    
    instance.didUpdateStateHandler = didUpdateStateHandler
}
