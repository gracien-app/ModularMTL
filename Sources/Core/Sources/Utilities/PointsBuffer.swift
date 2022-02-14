//
//  PointsBuffer.swift
//  
//
//  Created by Gracjan J on 14/02/2022.
//

import Foundation
import Metal

enum BufferStatus {
    case valid
    case tooSmall
    case tooBig
    case invalid
}

class PointsBuffer<Element> {
    private var device: MTLDevice
    private var buffer: MTLBuffer
    private var status: BufferStatus
    private var lastCount: UInt!
    
    private var bufferElementCount: UInt {
        let logicalLength = buffer.length
        let elementLogicalLength = MemoryLayout<Element>.stride
        
        return UInt(logicalLength / elementLogicalLength)
    }
    
    public func contents() -> MTLBuffer {
        return buffer
    }
    
    public init(with device: MTLDevice, size: UInt) {
        self.device = device
        
        let countAdjusted = size < 1000 ? 1000 : size
        let logicalSize = Int(countAdjusted) * MemoryLayout<Element>.stride
        
        guard let buffer = device.makeBuffer(length: logicalSize, options: .storageModePrivate) else {
            fatalError("[PointsBuffer] Error creating buffer of logical size \(logicalSize)")
        }
        
        self.buffer = buffer
        self.status = .invalid
    }
    
    public func updateStatus(points count: UInt) {
        if lastCount != nil && count == lastCount {
            status = .valid
        }
        else {
            if count > bufferElementCount {
                status = .tooSmall
            }
            else {
                let tempReducedSize = bufferElementCount / 4
                if tempReducedSize >= 1000 && count < tempReducedSize {
                    status = .tooBig
                }
                else {
                    status = .invalid
                }
            }
        }
        
        updateBuffer(points: count)
        self.lastCount = count
    }
    
    private func updateBuffer(points count: UInt) {
        switch self.status {
            case .tooSmall:
                let newLogicalSize = self.buffer.length * 2
                guard let buffer = device.makeBuffer(length: newLogicalSize, options: .storageModePrivate) else {
                    fatalError("[PointsBuffer] Error while enlarging the buffer.")
                }
                self.buffer = buffer
                break
            case .tooBig:
                let newLogicalSize = self.buffer.length / 2
                guard let buffer = device.makeBuffer(length: newLogicalSize, options: .storageModePrivate) else {
                    fatalError("[PointsBuffer] Error while enlarging the buffer.")
                }
                self.buffer = buffer
                break
            default:
                return
        }
        self.status = .invalid
    }
}
