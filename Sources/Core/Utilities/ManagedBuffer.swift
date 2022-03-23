import Foundation
import Metal

extension ManagedBuffer {
    enum BufferStatus {
        case valid
        case tooSmall
        case tooBig
        case invalid
    }
}

class ManagedBuffer<Element> {
    
    private var device: MTLDevice
    private var buffer: MTLBuffer
    private var status: BufferStatus
    private var lastNM: (UInt, Float)!
    private var minimalCapacity: UInt
    
    private var bufferElementCount: UInt {
        let logicalLength = buffer.length
        let elementLogicalLength = MemoryLayout<Element>.stride
        
        return UInt(logicalLength / elementLogicalLength)
    }
    
    public var isValid: Bool {
        return status == .valid ? true : false
    }
    
    public func contents() -> MTLBuffer {
        return buffer
    }
    
    public init?(with device: MTLDevice, count: UInt, minimum minCap: UInt, label: String) throws {
        self.device = device
        
        let minimum = minCap
        
        let countAdjusted = count < minimum ? minimum : count
        let logicalSize = Int(countAdjusted) * MemoryLayout<Element>.stride
        
        guard let buffer = device.makeBuffer(length: logicalSize, options: .storageModePrivate) else {
            throw RendererError.BufferCreationError(Details: "Error creating \(label) with logical size of \(logicalSize) bytes")
        }
        
        self.buffer = buffer
        self.buffer.label = label
        self.status = .invalid
        self.minimalCapacity = minimum
    }
    
    public func updateStatus(points count: UInt, multiplier M: Float) {
        if lastNM != nil && count == lastNM.0 && M == lastNM.1 {
            status = .valid
        }
        else {
            if count > bufferElementCount {
                status = .tooSmall
            }
            else {
                let tempReducedSize = bufferElementCount / 4
                if tempReducedSize >= self.minimalCapacity && count < tempReducedSize {
                    status = .tooBig
                }
                else {
                    status = .invalid
                }
            }
        }
        
        updateBuffer(points: count)
        self.lastNM = (count, M)
    }
    
    private func updateBuffer(points count: UInt) {
        var newLogicalSize = 0
        switch self.status {
            case .tooSmall:
                newLogicalSize = self.buffer.length * 2
                break
            case .tooBig:
                newLogicalSize = self.buffer.length / 2
                break
            default:
                return
        }
        
        guard let buffer = device.makeBuffer(length: newLogicalSize, options: .storageModePrivate) else {
            fatalError("[\(buffer.label ?? "Unnamed Buffer")] Error while enlarging the buffer.")
        }
        
        self.buffer = buffer
        self.status = .invalid
    }
}
