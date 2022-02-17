//
//  Fragment.metal
//  
//
//  Created by Gracjan J on 14/02/2022.
//

#include <metal_stdlib>
#include "../Header.metal"
using namespace metal;

/// Fragment function returning colour stored as vertex attribute.
fragment float4 fragmentFunction(Vertex v [[stage_in]]) {
    return v.colour;
};
