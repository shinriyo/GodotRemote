import Foundation

final class ProbeService: NetService {
    var resolveCalls = 0
    override func resolve(withTimeout timeout: TimeInterval) { resolveCalls += 1 }
}
let discovery = RemoteBonjour()
let service = ProbeService(domain: "local.", type: "_godotremote._tcp.", name: "late-callback", port: 24768)
discovery.start()
let browser = Mirror(reflecting: discovery).children.first { $0.label == "browser" }!.value as! NetServiceBrowser
discovery.netServiceBrowser(browser, didFind: service, moreComing: false)
precondition(service.resolveCalls == 1, "active discovery must still resolve services")
service.resolveCalls = 0
discovery.stop()
// NetService callbacks queued before teardown must not restart resolution.
discovery.netServiceBrowser(browser, didFind: service, moreComing: false)
if service.resolveCalls != 0 {
    fputs("FAIL: stopped discovery restarted service resolution from a late callback\n", stderr)
    exit(1)
}
print("PASS: stopped discovery ignores late service callbacks")
