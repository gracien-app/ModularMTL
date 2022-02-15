//
//  Fragment.metal
//  
//
//  Created by Gracjan J on 14/02/2022.
//

#include <metal_stdlib>
#include "../Header.metal"
using namespace metal;

fragment float4 fragmentFunction(Vertex v [[stage_in]]) {
    
    return v.colour;
};
