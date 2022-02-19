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

fragment float4 quadFragmentFunction(QuadVertex v [[stage_in]],
                                     texture2d<float, access::sample> inputTexture [[texture(0)]]) {
    
    constexpr sampler textureSampler;
    float4 color = inputTexture.sample(textureSampler, v.uv);

    return color;
}
