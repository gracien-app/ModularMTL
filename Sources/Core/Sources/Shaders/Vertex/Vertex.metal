//
//  Vertex.metal
//  
//
//  Created by Gracjan J on 14/02/2022.
//

#include <metal_stdlib>
#include "../Header.metal"
using namespace metal;

vertex Vertex pointVertexFunction(constant  float2  *vertices  [[buffer(0)]],
                                  const     uint    index      [[vertex_id]]) {

    return {
        .position = float4(vertices[index], 1.0, 1.0),
        .pointSize = 0.1,
        .colour = float4(1.0)
    };
}

vertex Vertex linesVertexFunction(constant  float4  *linesBuffer  [[buffer(0)]],
                                  const     uint    index         [[vertex_id]]) {
    
    int lineIndex = index / 2;
    int indexRemainder = index % 2;
    
    float4 vertexPosition = float4(0.0, 0.0, 1.0, 1.0);
    float4 vertexColour = float4(1.0);
    
    if (indexRemainder == 0) {
        vertexPosition.xy = linesBuffer[lineIndex].xy;
    }
    else {
        vertexPosition.xy = linesBuffer[lineIndex].zw;
        vertexColour = float4(float3(0.1), 1.0);
    }
    
    return {
        .position = vertexPosition,
        .pointSize = 0.1,
        .colour = vertexColour
    };
}
