//
//  fillAnimatedLines.metal
//
//
//  Created by Gracjan J on 14/02/2022.
//

#include <metal_stdlib>
using namespace metal;

kernel void fillAnimatedLines(constant uint &pointsCount       [[buffer(0)]],
                              constant float &multiplier       [[buffer(1)]],
                              device simd_float2 *pointsBuffer [[buffer(2)]],
                              device simd_float4 *linesBuffer  [[buffer(3)]],
                              const uint index                 [[thread_position_in_grid]]) {
    
    if (index >= pointsCount) {
        return;
    }

    int fromIndex = index;
    float toIndex = fromIndex * multiplier;
    
    float rotationOffset = M_PI_F;
    float radius = 0.9;
    float angle = (2 * M_PI_F) / float(pointsCount);
    
    float2 point = float2(0.0);
    
    point.x = radius * cos(rotationOffset - angle * toIndex);
    point.y = radius * sin(rotationOffset - angle * toIndex);

    linesBuffer[index] = float4(pointsBuffer[fromIndex], point);
    return;
}
