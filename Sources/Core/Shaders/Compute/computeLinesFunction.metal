//
//  computeLinesFunction.metal
//
//
//  Created by Gracjan J on 14/02/2022.
//

#include <metal_stdlib>
using namespace metal;

/// Compute kernel used to fill target buffer with proper connections based on multiplier parameter provided.
///
/// Provided buffer contains information about each connection between two points, where:
/// Connection is a 4-element vector with
///         .xy - 2D coordinates of the first point,
///         .zw - 2D coordinates of the second point
///
/// Check is performed at the beginning to prevent writing to memory outside the bounds of both buffers (identical element count).
///
kernel void computeLinesFunction(device    float4  *linesBuffer   [[buffer(0)]],
                                 constant  uint    &pointsCount   [[buffer(1)]],
                                 constant  float   &multiplier    [[buffer(2)]],
                                 constant  float   &radius        [[buffer(3)]],
                                 const     uint    index          [[thread_position_in_grid]])
{
    if (index >= pointsCount) { return; }
    
    float rotationOffset = M_PI_F;
    float angle = (2 * M_PI_F) / float(pointsCount);
    
    float2 fromPoint, toPoint = float2(0.0);
    
    fromPoint.x = radius * cos(rotationOffset - angle * index);
    fromPoint.y = radius * sin(rotationOffset - angle * index);
    
    float toIndex = index * multiplier;
    toPoint.x = radius * cos(rotationOffset - angle * toIndex);
    toPoint.y = radius * sin(rotationOffset - angle * toIndex);

    linesBuffer[index] = float4(fromPoint, toPoint);
    return;
}
