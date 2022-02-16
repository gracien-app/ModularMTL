//
//  fillStaticLines.metal
//
//
//  Created by Gracjan J on 14/02/2022.
//

#include <metal_stdlib>
using namespace metal;


kernel void fillStaticLines(constant uint &pointsCount       [[buffer(0)]],
                            constant uint &multiplier        [[buffer(1)]],
                            device float2 *pointsBuffer      [[buffer(2)]],
                            device simd_float4 *linesBuffer  [[buffer(3)]],
                            const uint index                 [[thread_position_in_grid]]) {
    
    if (index >= pointsCount) {
        return;
    }
    
    int fromIndex = index;
    int toIndex = (fromIndex * multiplier) % pointsCount;
    
    linesBuffer[index] = float4(pointsBuffer[fromIndex], pointsBuffer[toIndex]);
    return;
}
