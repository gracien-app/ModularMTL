//
//  MenuTextView.swift
//
//
//  Created by Gracjan J on 13/02/2022.
//

import SwiftUI

struct MenuTextView: View {
    let firstChar: String
    let remainder: String
    
    let dataString: String?
    let dataBinding: Binding<Bool>?
    
    let isDisabled: Bool
    
    private let size: CGFloat = 32
    private let tracking: CGFloat = 25
    
    
    init(label: String, _ dataString: String? = nil, dataBinding: Binding<Bool>? = nil, isDisabled: Bool = false) {
        var tempLabel = label
        firstChar = String(tempLabel.removeFirst())
        remainder = tempLabel
        self.dataString = dataString
        self.dataBinding = dataBinding
        self.isDisabled = isDisabled
    }
    
    
    var body: some View {
        HStack(alignment: .center , spacing: 0) {
            
            firstCharBody
            remainderBody
            dataBody
            
            if let dataBinding = dataBinding  {
                Toggle(isOn: dataBinding, label: {})
                    .disabled(self.isDisabled)
                    .toggleStyle(
                        SwitchToggleStyle(tint: Color(.displayP3, red: 0.313,green: 0.392, blue: 0.51, opacity: 0.1))
                    )
            }
            
            Spacer()
        }
    }
    
    
    var dataBody: some View {
        Text(" " + (dataString ?? ""))
            .font(.system(size: self.size))
            .fontWeight(.ultraLight)
            .tracking(self.tracking/5.0)
    }
    
    
    var remainderBody: some View {
        Text(remainder)
            .font(.system(size: self.size))
            .fontWeight(.ultraLight)
            .tracking(self.tracking)
    }
    
    var firstCharBody: some View {
        ZStack {
            Text(firstChar)
                .font(.system(size: self.size))
                .fontWeight(.thin)
                .tracking(self.tracking)
                .foregroundColor(.white)
            Text(firstChar)
                .font(.system(size: self.size))
                .fontWeight(.heavy)
                .tracking(self.tracking)
                .foregroundStyle(.blue)
                .blur(radius: 30.0)
        }
    }
}
