//
//  ARSceneViewModel.swift
//  TubePipe
//
//  Created by fredrik sundström on 2024-01-12.
//
import SwiftUI
import SceneKit

class ARSceneViewModel: ObservableObject {
    var scnScene = SCNScene()
    var initialZoomSet:Bool = false
    var renderState:UInt16 = 0
    var renderNode:RenderNode = .NODE_MUFF
    var parentNode:SCNNode = SCNNode()
    var meshCube:MeshCube = MeshCube()
    
    //MARK: Do Step 0
    func setRenderState(_ state:UInt16){
        renderState = state
    }
    
    //MARK: Do Step 1.0
    func buildModelFromTubePoints(_ points:[TPoint],dimension:CGFloat) {
        if(!muffShouldBeVisible){ return }
        guard let path = buildVerticesPath(points) else { return }
        renderNode = .NODE_MUFF
        let circle = buildCircleBySteps(CIRCLE_SECTORS, radius: (dimension/2.0)/10000.0)
        let pipe = Pipe(pathPoints: path, contourPoints: circle)
        if pipe.abort { return }
        collectVertexPoints(pipe,buildEndCapCircles:false)
        meshCube.buildOBJType()
        populateScene(material:getMaterial())
        meshCube.reset()
    }
    
    //MARK: Do Step 1.1
    func buildSteelFromTubePoints(_ points:[TPoint],dimension:CGFloat){
        if(!steelShouldBeVisible){ return }
        guard let path = buildVerticesPath(points) else { return }
        renderNode = .NODE_STEEL
        let circle = buildCircleBySteps(CIRCLE_SECTORS, radius: dimension/2.0)
        let pipe = Pipe(pathPoints: path, contourPoints: circle)
        if pipe.abort { return }
        collectVertexPoints(pipe,buildEndCapCircles:false)
        meshCube.buildOBJType()
        populateScene(material:getMaterial())
        meshCube.reset()
    }
    
    //MARK: Do Step 2
    func buildVerticesPath(_ points:[TPoint]) -> [SCNVector3]?{
        if points.count < 2 { return nil }
        var vertices:[SCNVector3] = []
        for p in points{
            vertices.append(SCNVector3(x: SCNFloat(p.x)/10000.0, y: 0.0, z: SCNFloat(p.y)/10000.0))
        }
        return vertices
    }
    
    //MARK: Do Step 3
    func buildCircleBySteps(_ steps:Int,radius:CGFloat) -> [SCNVector3]{
        var points:[SCNVector3] = []
        let divSteps = Double(steps)
        let degress = (isMuff && splitHalf) ? 1.0 : 2.0
        let pi2 = acos(-1) * degress
        for i in (0..<steps+1){
            let a = pi2/divSteps * Double(i)
            let x = radius * cos(a)
            let y = radius * sin(a)
            points.append(SCNVector3(x: SCNFloat(x), y: SCNFloat(y), z: SCNFloat(0.0)))
        }
        return points
    }
    
    //MARK: Do Step 4
    func collectVertexPoints(_ pipe:Pipe,buildEndCapCircles:Bool){
        let count = pipe.contoursCount
        if(count > 1 && buildEndCapCircles){ collectVertexCirclePoints(pipe.getContourFirstLast())
        }
        collectVertexPipePoints(pipe: pipe, count: count)
    }
    
    //MARK: Do Step 5
    func populateScene(material:SCNMaterial){
        let indexData = NSData(bytes: meshCube.obj.indices, length: MemoryLayout<UInt16>.size * meshCube.obj.indices.count) as Data
        let vertexSource = SCNGeometrySource(vertices: meshCube.obj.vertices)
        let newElement = SCNGeometryElement(data: indexData,
                                            primitiveType: .triangles,
                                            primitiveCount: meshCube.obj.indices.count/3,
                                            bytesPerIndex: MemoryLayout<UInt16>.size)
        let geometry = SCNGeometry(sources: [vertexSource], elements: [newElement])
        geometry.materials = [material]
        let node = SCNNode(geometry: geometry)
        node.name = renderNode.rawValue
        parentNode.addChildNode(node)
     }
    
    func publishScene(){
        scnScene.rootNode.addChildNode(parentNode)
    }
    
    func reset(){
        for node in parentNode.childNodes{
            node.removeFromParentNode()
        }
        for node in scnScene.rootNode.childNodes{
            node.removeFromParentNode()
        }
        parentNode = SCNNode()
        meshCube.reset()
    }
}

extension ARSceneViewModel{
    func setRenderBit(_ bit:UInt16){ renderState |= bit }
    func clearRenderBit(_ bit:UInt16){ renderState &= ~(1<<bit) }
    func clearRenderState(){ renderState = 0}
    
    func clearRenderRenderPart(){
        renderState &= ~(RenderOption.indexOf(op: .SHOW_STEEL) |
                         RenderOption.indexOf(op: .SHOW_MUFF))
    }
    func clearRenderSizePart(){
        renderState &= ~(RenderOption.indexOf(op: .FULL_SIZE_MUFF) |
                         RenderOption.indexOf(op: .SCALED_SIZE_MUFF))
    }
    func clearRenderDrawPart(){
        renderState &= ~(RenderOption.indexOf(op: .WHOLE_MUFF) |
                         RenderOption.indexOf(op: .SPLIT_MUFF))
    }
    func clearRenderFillPart(){
        renderState &= ~(RenderOption.indexOf(op: .FILL_MUFF) |
                         RenderOption.indexOf(op: .LINE_MUFF) |
                         RenderOption.indexOf(op: .SEE_THROUGH_MUFF))
    }
    func clearRenderWorldAxisPart(){
        renderState &= ~(RenderOption.indexOf(op: .WORLD_AXIS))
    }
    func isRenderBitSet(_ bit:UInt16) -> Bool{ return (renderState & (1 << bit)) != 0 }
    
    var splitHalf:Bool{ isRenderBitSet(RenderOption.indexOfBit(op: .SPLIT_MUFF))}
    var isMuff:Bool{ renderNode == .NODE_MUFF }
    var isWorldAxis:Bool{ isRenderBitSet(RenderOption.indexOfBit(op: .WORLD_AXIS))}
    var steelShouldBeVisible:Bool{ isRenderBitSet(RenderOption.indexOfBit(op: .SHOW_STEEL))}
    var muffShouldBeVisible:Bool{ isRenderBitSet(RenderOption.indexOfBit(op: .SHOW_MUFF))}
    
    var renderRenderPart:UInt16{
        let clearBits:UInt16 =
        RenderOption.indexOf(op: .SHOW_STEEL) +
        RenderOption.indexOf(op: .SHOW_MUFF)
        return renderState & clearBits
    }
    
    var renderSizePart: UInt16{
        let clearBits:UInt16 =
        RenderOption.indexOf(op: .FULL_SIZE_MUFF) +
        RenderOption.indexOf(op: .SCALED_SIZE_MUFF)
        return renderState & clearBits
    }
    var renderDrawPart: UInt16{
        let clearBits:UInt16 =
        RenderOption.indexOf(op: .SPLIT_MUFF) +
        RenderOption.indexOf(op: .WHOLE_MUFF)
        return renderState & clearBits
    }
    
    var renderFillPart: UInt16{
        let clearBits:UInt16 =
        RenderOption.indexOf(op: .SEE_THROUGH_MUFF) +
        RenderOption.indexOf(op: .LINE_MUFF) +
        RenderOption.indexOf(op: .FILL_MUFF)
        return renderState & clearBits
    }
    
    func collectVertexPipePoints(pipe:Pipe,count:Int){
        var vertices:[SCNVector3] = []
        let doSplitHalf = isMuff && splitHalf
        for i in (0..<count-1){
            let c1 = pipe.getContour(index: i)
            let c2 = pipe.getContour(index: i+1)
            let start = 0
            let stop = c2.count
            if(doSplitHalf){ vertices.append(c1[0])}
            for j in (start..<stop){
                vertices.append(c1[j])
                vertices.append(c2[j])
            }
            if(doSplitHalf){ vertices.append(vertices[vertices.count-1])}
        }
        meshCube.populateWithPipeVertices(vertices)
    }
    
    func collectVertexCirclePoints(_ contours:[[SCNVector3]?]){
        var cnt = 0
        for contour in contours{
            guard let contour = contour else { continue }
            var vertices:[SCNVector3] = []
            for j in (0..<contour.count-1){
                let c = contour[j]
                let c1 = contour[j+1]
                vertices.append(c)
                vertices.append(c1)
                if(j == contour.count-2){
                    vertices.append(contour[0])
                }
            }
            meshCube.populateWithCircleVertices(vertices,first:cnt)
            cnt+=1
        }
    }
    
    func getMaterial() -> SCNMaterial{
        switch renderNode{
        case .NODE_STEEL:
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.black
            material.isDoubleSided = true
            material.ambient.contents = UIColor.black
            material.lightingModel = .constant
            material.emission.contents = UIColor.black
            return material
        case .NODE_MUFF:
            let material = SCNMaterial()
            switch renderFillPart{
            case RenderOption.indexOf(op: .FILL_MUFF): material.fillMode = .fill
            case RenderOption.indexOf(op: .LINE_MUFF): material.fillMode = .lines
            case RenderOption.indexOf(op: .SEE_THROUGH_MUFF):
                material.fillMode = .fill
                material.transparency = 0.5
            default: material.fillMode = .fill
            }
            material.isDoubleSided = true
            return material
        }
    }
}

extension ARSceneViewModel{
    
    func addWorldAxis(){
        if(!isWorldAxis){ return }
        let axis:SCNNode = SCNNode()
        let worldAxisDirection: [WorldAxisDirection] = [
            WorldAxisDirection(axisDirection: .AXIS_X,extrusionDepth: 2.0),
            WorldAxisDirection(axisDirection: .AXIS_Y,extrusionDepth: 2.0),
            WorldAxisDirection(axisDirection: .AXIS_Z,extrusionDepth: 2.0)]
        
        for dir in worldAxisDirection {
            let box = WorldAxisBox.defaultBox
            box.materials = WorldAxisBox.defaultMaterial(color: dir.color)
            
            let node = SCNNode(geometry: box)
            node.eulerAngles = dir.eulerAngleNode
            
            switch dir.axisDirection {
                case .AXIS_X: node.position.x += dir.addDirectionValue
                case .AXIS_Y: node.position.y += dir.addDirectionValue
                case .AXIS_Z: node.position.z += dir.addDirectionValue
            }
            node.addChildNode(dir.textNode)
            axis.addChildNode(node)
        }
        let maxZ = parentNode.boundingBox.max.z
        axis.position = SCNVector3(x: 0, y:0, z: maxZ/2.0)
        scnScene.rootNode.addChildNode(axis)
    }
}

extension ARSceneViewModel{
    
    func rotateParentNode() {
        let rot1 = SCNAction.rotate(by: CGFloat(90).degToRad(), around: SCNVector3(1,0,0), duration: 0)
        parentNode.runAction(rot1)
        let rot2 = SCNAction.rotate(by: CGFloat(180).degToRad(), around: SCNVector3(0,1,0), duration: 0)
        parentNode.runAction(rot2)
        let rot3 = SCNAction.rotate(by: CGFloat(180).degToRad(), around: SCNVector3(0,0,1), duration: 0)
        parentNode.runAction(rot3)
    }
    
    func zoomScene(){
        if(!initialZoomSet){
            let newZ = scnScene.rootNode.boundingBox.min.z + scnScene.rootNode.boundingBox.max.z
            let zoom = SCNAction.move(by: SCNVector3(x: 0, y: 0, z: -newZ*2), duration: 0)
            scnScene.rootNode.runAction(zoom)
            initialZoomSet = true
        }
    }
    
    func updatePosition(onAxis axis:AxisDirection,with pos:SCNFloat){
        switch axis{
        case .AXIS_X:   scnScene.rootNode.simdLocalTranslate(by: simd_float3(pos,0,0))
        case .AXIS_Y:   scnScene.rootNode.simdLocalTranslate(by: simd_float3(0,pos,0))
        case .AXIS_Z:   scnScene.rootNode.simdLocalTranslate(by: simd_float3(0,0,pos))
        }
    }
    
    /*
    func addCamera(){
        scnScene.rootNode.addChildNode(camera.cameraEye)
    }*/
    //scnScene.rootNode.orientation = SCNQuaternion(x: Float.pi/2, y: 0, z: 0, w: 0)
    
}
