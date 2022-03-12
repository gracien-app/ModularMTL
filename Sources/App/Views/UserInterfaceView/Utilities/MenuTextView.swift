//
//  MenuTextView.swift
//
//
//  Created by Gracjan J on 13/02/2022.
//

import SwiftUI

struct MenuTextView: View {
    var firstChar: String
    var remainder: String
    var dataString: String?
    var dataBinding: Binding<Bool>?
    var enabled: Binding<Bool>?
    let disabled: Bool
    
    let size: CGFloat = 32
    let tracking: CGFloat = 25
    
    init(label: String, _ dataString: String? = nil, dataBinding: Binding<Bool>? = nil, disabled: Bool = false) {
        var tempLabel = label
        firstChar = String(tempLabel.removeFirst())
        remainder = tempLabel
        self.dataString = dataString
        self.dataBinding = dataBinding
        self.disabled = disabled
    }
    
    var body: some View {
        HStack(alignment: .center , spacing: 0) {
            
            firstCharacterBody
            
            Text(remainder)
                .font(.system(size: self.size))
                .fontWeight(.ultraLight)
                .tracking(self.tracking)
            
            if let dataString = dataString {
                Text(" " + dataString)
                    .font(.system(size: self.size))
                    .fontWeight(.ultraLight)
                    .tracking(self.tracking/5.0)
            }
            
            if let dataBinding = dataBinding  {
                Toggle(isOn: dataBinding, label: {})
                    .toggleStyle(SwitchToggleStyle(tint: Color(.displayP3,
                                                               red: 0.313,
                                                               green: 0.392,
                                                               blue: 0.51,
                                                               opacity: 0.1)))
                    .disabled(self.disabled)
            }
            
            Spacer()
                
        }
    }
    
    var firstCharacterBody: some View {
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
