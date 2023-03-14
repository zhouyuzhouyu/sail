import NetworkExtension

//let appGroup = "group.com.yuzhou.XCat"

// See https://github.com/eycorsican/leaf/blob/master/README.zh.md#conf for more conf examples.
/*
let conf = """
[General]
loglevel = trace
dns-server = 8.8.8.8, 114.114.114.114
tun-fd = REPLACE-ME-WITH-THE-FD
routing-domain-resolve = true
dns-interface = 192.168.20.1

[Proxy]
Direct = direct
Trojan = trojan, z002.zoyu.club, 10010, password = acfe487f-5523-4ed2-bb68-9b2ba557646d

[Proxy Group]
UrlTest = url-test, Trojan, check-interval = 600

[Rule]
EXTERNAL, site:cn, Direct
EXTERNAL, mmdb:cn, Direct
FINAL, UrlTest
"""
*/
//EXTERNAL, site:cn, Direct
//EXTERNAL, mmdb:cn, Direct


/*
let conf = """
[General]
loglevel = trace
dns-server = 8.8.8.8, 114.114.114.114
tun-fd = REPLACE-ME-WITH-THE-FD
routing-domain-resolve = true
dns-interface = 192.168.1.20

[Proxy]
Direct = direct
Vmess = vmess, z002.zoyu.club, 10012, username=acfe487f-5523-4ed2-bb68-9b2ba557646d, ws=true, tls=true, ws-path=/cctv13/hd.m3u8, ws-host=z002.zoyu.club

[Rule]
EXTERNAL, site:cn, Direct
EXTERNAL, mmdb:cn, Direct
FINAL, Vmess
"""
*/
//,



/*
let conf = """
{
    "log": {
        "level": "debug"
    },
    "inbounds": [
        {
            "protocol": "tun",
            "settings": {
                "fd": \(fd)
            },
            "tag": "tun"
        }
    ],
    "outbounds": [
        {
            "protocol": "socks",
            "settings": {
                "address": "127.0.0.1",
                "port": 8080
            },
            "tag": "clash"
        }
    ]
}
"""
*/
class PacketTunnelProvider: NEPacketTunnelProvider {
    
    private lazy var adapter: LeafAdapater = {
        LeafAdapater.setPacketTunnelProvider(with: self)
        return LeafAdapater.shared()
    }()

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        let tunnelNetworkSettings = createTunnelSettings()
        setTunnelNetworkSettings(tunnelNetworkSettings) { [weak self] error in
            if let error = error {
                return completionHandler(error)
            }
            completionHandler(nil)
            self?.adapter.start(completionHandler: { error in
                
            });

        }
    }

    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        self.adapter.stop { error in
            if let error = error {
                Logger.log(error.localizedDescription, to: Logger.vpnLogFile)
            }
            
            completionHandler()
        }
    }

    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        // Add code here to handle the message.
        if let handler = completionHandler {
            handler(messageData)
        }
    }

    override func sleep(completionHandler: @escaping () -> Void) {
        // Add code here to get ready to sleep.
        completionHandler()
    }

    override func wake() {
        // Add code here to wake up.
    }
    
    func createTunnelSettings() -> NEPacketTunnelNetworkSettings  {
        let newSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "240.0.0.10")
        newSettings.ipv4Settings = NEIPv4Settings(addresses: ["240.0.0.1"], subnetMasks: ["255.255.255.0"])
        newSettings.ipv4Settings?.includedRoutes = [NEIPv4Route.default()]
        newSettings.ipv6Settings = NEIPv6Settings(addresses: ["FC00::0001"], networkPrefixLengths: [7])
        newSettings.ipv6Settings?.includedRoutes = [NEIPv6Route.default()]
        newSettings.proxySettings = nil
        newSettings.dnsSettings = NEDNSSettings(servers: ["223.5.5.5", "8.8.8.8"])
        newSettings.mtu = 1500
        return newSettings
    }
}
