//
//  SCNNodeExtensions.swift
//  TubePipe
//
//  Created by fredrik sundström on 2024-02-14.
//
import ARKit
extension SCNNode {
    func parentOfType<T: SCNNode>() -> T? {
        var node: SCNNode? = self
        repeat {
            if let node = node as? T { return node }
            node = node?.parent
        } while node != nil
        return nil
    }
}
