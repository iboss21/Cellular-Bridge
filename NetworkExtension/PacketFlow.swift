import NetworkExtension

class PacketFlowManager {
    private var isHandlingPackets = false
    private let packetProcessor = PacketProcessor()
    
    func startHandlingPackets(_ packetFlow: NEPacketFlow?) {
        guard !isHandlingPackets else { return }
        isHandlingPackets = true
        
        readPackets(from: packetFlow)
    }
    
    func stopHandlingPackets() {
        isHandlingPackets = false
    }
    
    private func readPackets(from packetFlow: NEPacketFlow?) {
        guard let packetFlow = packetFlow else { return }
        
        packetFlow.readPackets { [weak self] packets, protocols in
            self?.processPackets(packets, protocols: protocols, packetFlow: packetFlow)
        }
    }
    
    private func processPackets(_ packets: [Data], protocols: [NSNumber], packetFlow: NEPacketFlow) {
        guard isHandlingPackets else { return }
        
        let processedPackets = packets.map { packetProcessor.processPacket($0) }
        
        packetFlow.writePackets(processedPackets, withProtocols: protocols)
        readPackets(from: packetFlow)
    }
}

class PacketProcessor {
    func processPacket(_ packet: Data) -> Data {
        // Process the packet (e.g., encrypt, modify headers, etc.)
        return packet
    }
}
