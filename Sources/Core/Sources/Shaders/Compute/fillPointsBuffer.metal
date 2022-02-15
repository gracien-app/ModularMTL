//
//  fillPointsBuffer.metal
//
//
//  Created by Gracjan J on 13/02/2022.
//

#include <metal_stdlib>
using namespace metal;


kernel void fillPointsBuffer(constant uint &pointsCount          [[buffer(0)]],
                               constant float &circleRadius       [[buffer(1)]],
                               device simd_float2 *pointsBuffer   [[buffer(2)]],
                               const uint index                   [[thread_position_in_grid]]) {
    
    if (index >= pointsCount) {
        return;
    }
    
    float rotationOffset = M_PI_F;
    float radius = clamp(circleRadius, 0.0, 1.0);
    float angle = (2 * M_PI_F) / float(pointsCount);
    
    float2 point = float2(0.0);
    
    point.x = radius * cos(rotationOffset - angle * index);
    point.y = radius * sin(rotationOffset - angle * index);
    
    pointsBuffer[index] = point;
    return;
}
