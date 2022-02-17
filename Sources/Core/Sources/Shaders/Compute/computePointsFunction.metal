//
//  computePointsFunction.metal
//
//
//  Created by Gracjan J on 13/02/2022.
//

#include <metal_stdlib>
using namespace metal;

/// Compute kernel filling target buffer with equally distributed N points on a circle of given radius.
///
/// Rotation offset is used to rotate the whole figure (point with index "0" located on the left side).
/// Check is performed at the beginning to prevent writing to memory outside the bounds of a buffer.
///
kernel void computePointsFunction(device    float2  *pointsBuffer  [[buffer(0)]],
                                  constant  uint    &pointsCount   [[buffer(1)]],
                                  constant  float   &circleRadius  [[buffer(2)]],
                                  const     uint    index          [[thread_position_in_grid]])
{
    if (index >= pointsCount) { return; }
    
    float rotationOffset = M_PI_F;
    float radius = clamp(circleRadius, 0.0, 1.0);
    
    float angle = (2 * M_PI_F) / float(pointsCount);
    
    float2 point = float2(0.0);
    point.x = radius * cos(rotationOffset - angle * index);
    point.y = radius * sin(rotationOffset - angle * index);
    
    pointsBuffer[index] = point;
    return;
}
