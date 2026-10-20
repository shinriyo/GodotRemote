import Foundation
import Darwin
#if canImport(UIKit)
import UIKit
#endif

// Bonjour performs LAN discovery. UDP here is only an in-process bridge on
// loopback, never broadcast or multicast traffic from the app itself.
final class RemoteBonjour: NSObject, NetServiceBrowserDelegate, NetServiceDelegate {
    static let shared = RemoteBonjour()
    private let browser = NetServiceBrowser()
    private var services: [String: NetService] = [:]
    private var endpoints: [String: [String: Any]] = [:]
    private var timer: Timer?
    private var socketFD: Int32 = -1
    private var state = "searching"

    private func key(_ service: NetService) -> String {
        service.name + "." + service.type + service.domain
    }

    func start() {
        guard timer == nil else { return }
        socketFD = socket(AF_INET, SOCK_DGRAM, 0)
        browser.delegate = self
        browser.searchForServices(ofType: "_godotremote._tcp.", inDomain: "local.")
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in self?.sendSnapshot() }
        #if canImport(UIKit)
        NotificationCenter.default.addObserver(self, selector: #selector(resume), name: UIApplication.didBecomeActiveNotification, object: nil)
        #endif
    }

    @objc private func resume() {
        browser.stop()
        for service in services.values { service.stop() }
        services.removeAll()
        endpoints.removeAll()
        state = "searching"
        browser.searchForServices(ofType: "_godotremote._tcp.", inDomain: "local.")
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        browser.stop()
        for service in services.values { service.stop() }
        services.removeAll()
        endpoints.removeAll()
        NotificationCenter.default.removeObserver(self)
        if socketFD >= 0 { close(socketFD); socketFD = -1 }
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        guard services.count < 32 else { return }
        services[key(service)] = service
        service.delegate = self
        service.resolve(withTimeout: 5)
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        services.removeValue(forKey: key(service))?.stop()
        endpoints.removeValue(forKey: key(service))
        sendSnapshot()
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String: NSNumber]) {
        state = "unavailable"
        sendSnapshot()
    }

    func netServiceDidResolveAddress(_ sender: NetService) {
        guard let txt = sender.txtRecordData(),
              let version = NetService.dictionary(fromTXTRecord: txt)["v"],
              String(data: version, encoding: .utf8) == "1",
              sender.port > 0, sender.port <= 65535 else { return }
        var host = sender.hostName ?? ""
        for address in sender.addresses ?? [] {
            let ipv4: String? = address.withUnsafeBytes { raw in
                guard let ptr = raw.baseAddress, raw.count >= MemoryLayout<sockaddr_in>.size,
                      ptr.assumingMemoryBound(to: sockaddr.self).pointee.sa_family == AF_INET else { return nil }
                var name = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                guard getnameinfo(ptr.assumingMemoryBound(to: sockaddr.self), socklen_t(raw.count), &name, socklen_t(name.count), nil, 0, NI_NUMERICHOST) == 0 else { return nil }
                return String(cString: name)
            }
            if let ipv4 { host = ipv4; break }
        }
        guard !host.isEmpty else { return }
        endpoints[key(sender)] = ["id": key(sender), "name": sender.name, "host": host, "port": sender.port]
        state = "searching"
        sendSnapshot()
    }

    private func sendSnapshot() {
        guard socketFD >= 0 else { return }
        let rows = endpoints.keys.sorted().compactMap { endpoints[$0] }
        guard let data = try? JSONSerialization.data(withJSONObject: ["protocol": 1, "state": state, "servers": rows]), data.count <= 16384 else { return }
        var target = sockaddr_in()
        target.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        target.sin_family = sa_family_t(AF_INET)
        target.sin_port = UInt16(22767).bigEndian
        target.sin_addr.s_addr = inet_addr("127.0.0.1")
        data.withUnsafeBytes { buffer in
            withUnsafePointer(to: &target) { pointer in
                pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) { address in
                    _ = sendto(socketFD, buffer.baseAddress, buffer.count, 0, address, socklen_t(MemoryLayout<sockaddr_in>.size))
                }
            }
        }
    }
}

@_cdecl("godot_remote_bonjour_start")
public func godotRemoteBonjourStart() {
    DispatchQueue.main.async { RemoteBonjour.shared.start() }
}

@_cdecl("godot_remote_bonjour_stop")
public func godotRemoteBonjourStop() {
    DispatchQueue.main.async { RemoteBonjour.shared.stop() }
}
