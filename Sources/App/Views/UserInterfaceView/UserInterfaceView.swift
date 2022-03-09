import SwiftUI
import ModularMTLCore

struct UserInterfaceView: View {
    
    @EnvironmentObject var data: RendererObservableData
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 25) {
                MenuTextView(label: "MULTIPLE", String(format: "%.2f", data.multiplier))
                MenuTextView(label: "OFFSET", String(format: "%.3f", data.animationStep))
                MenuTextView(label: "DISPERSAL", String(format: "%u", data.pointsCount))
                MenuTextView(label: "U")
                MenuTextView(label: "LATENCY", data.frametimeInMs)
                MenuTextView(label: "ANIMATE", nil, dataBinding: $data.animation)
                
                MenuTextView(label: "RADIATE", nil, dataBinding: $data.blur,
                             disabled: data.status == .Limited ? true : false)
            }
        }
    }
}
