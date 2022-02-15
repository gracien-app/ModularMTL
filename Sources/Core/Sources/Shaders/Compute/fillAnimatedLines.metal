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
   
    return;
}
