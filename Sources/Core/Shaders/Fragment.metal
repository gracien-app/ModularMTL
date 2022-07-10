//
//  Fragment.metal
//  
//
//  Created by Gracjan J on 14/02/2022.
//

#include <metal_stdlib>
#include "Header.metal"
using namespace metal;

/// Fragment function returning colour stored as vertex attribute.
///
fragment float4 fragmentFunction(Vertex v [[stage_in]]) {
    return v.colour;
};

fragment float4 quadFragmentFunction(QuadVertex v [[stage_in]],
                                     constant bool &blurEnabled [[buffer(0)]],
                                     constant float &multiplier [[buffer(1)]],
                                     texture2d<float, access::sample> inputTexture [[texture(0)]],
                                     texture2d<float, access::sample> blurTexture [[texture(1)]]) {
    
    constexpr sampler textureSampler;
    float4 color = inputTexture.sample(textureSampler, v.uv);
    
    if (blurEnabled == true && color.x == 0.0 && color.y == 0.0 && color.z == 0.0) {
        color = blurTexture.sample(textureSampler, v.uv) * (0.45 + 0.05 * sin(multiplier * 10));

        color.xyz / 2.2;
    }

    return color;
}
