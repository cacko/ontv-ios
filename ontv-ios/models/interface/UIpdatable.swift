//
//  UIpdatable.swift
//  ontv-ios
//
//  Created by Alex on 02/01/2022.
//

import Foundation

protocol Updatable {

  static var needsUpdate: Bool { get }

  static var isLoaded: Bool { get }

}
