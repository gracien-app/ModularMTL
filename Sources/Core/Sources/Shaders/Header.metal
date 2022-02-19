//
//  Header.metal
//  
//
//  Created by Gracjan J on 14/02/2022.
//

#include <metal_stdlib>
using namespace metal;

/// Vertex structure, uses [[sample_perspective]] to achieve custom interpolation of colour.
struct Vertex {
    float4 position [[position]];
    float4 colour [[sample_perspective]];
};

struct QuadVertex {
    float4 position [[position]];
    float2 uv;
};
