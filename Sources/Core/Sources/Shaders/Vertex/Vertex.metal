//
//  Vertex.metal
//  
//
//  Created by Gracjan J on 14/02/2022.
//

#include <metal_stdlib>
#include "../Header.metal"
using namespace metal;


/// Vertex function which returns vertices in order appropriate for line rendering mode.
///
/// Lines buffer contains information about each connection, each element contains
/// 2D coordinates of both ends of the line.
/// To properly read the data, index is divided by two, to compensate how data is structured.
/// Remainder indicates whether we are looking for starting or ending point in the connection.
///
/// Colour of each vertex is defined here, end points are treated as almost black points to create a linear interpolation of color
/// which adds a degree of depth to the lines.
///
vertex Vertex linesVertexFunction(constant  float4  *linesBuffer  [[buffer(0)]],
                                  const     uint    index         [[vertex_id]]) {
    
    int lineIndex = index / 2;
    int indexRemainder = index % 2;
    
    float4 vertexPosition = float4(0.0, 0.0, 1.0, 1.0);
    float4 vertexColour = float4(0.235, 0.435, 0.79, 1.0) / 2.2;
    
    if (indexRemainder == 0) {
        vertexPosition.xy = linesBuffer[lineIndex].xy;
    }
    else {
        vertexPosition.xy = linesBuffer[lineIndex].zw;
        vertexColour = float4(float3(0.001), 1.0);
    }
    
    return {
        .position = vertexPosition,
        .colour = vertexColour
    };
}
