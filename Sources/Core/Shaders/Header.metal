//
//  Header.metal
//  
//
//  Created by Gracjan J on 14/02/2022.
//

#include <metal_stdlib>
using namespace metal;

/// Vertex structure, uses [[sample_perspective]] to interpolate colour of lines.
struct Vertex {
    float4 position [[position]];
    float4 colour [[sample_perspective]];
};

/// Quad vertex data on which texture is rendered in window view.
constant float2 quadVertices[] = {
    float2(-1, -1),
    float2(-1,  1),
    float2( 1,  1),
    float2(-1, -1),
    float2( 1,  1),
    float2( 1, -1)
};

/// Vertex structure used in drawing quad. Contains both position and UV coordinates to sample texture on geometry.
struct QuadVertex {
    float4 position [[position]];
    float2 uv;
};
