//
//  Helper.swift
//  
//
//  Created by Gracjan J on 11/03/2022.
//

import Foundation

public enum Helper {
    public static func merge<T: Error>(_ functions: (()->Result<Void, T>)...) -> Result<Void, T> {
        for function in functions {
            let result = function()
            
            switch result {
                case .failure(_):
                    return result
                default:
                    break
            }
        }
        return .success(Void())
    }
}
