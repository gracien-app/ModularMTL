//
//  Header.metal
//  
//
//  Created by Gracjan J on 14/02/2022.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float4 position [[position]];
    float pointSize [[point_size]];
    float4 colour [[sample_perspective]];
};
