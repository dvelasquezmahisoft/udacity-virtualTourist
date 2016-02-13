//
//  StringExtension.swift
//  VirtualTourist
//
//  Created by Daniela Velasquez on 2/13/16.
//  Copyright © 2016 Mahisoft. All rights reserved.
//

import Foundation

extension String {
    
    static func className(aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).componentsSeparatedByString(".").last!
    }
    
}