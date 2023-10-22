/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Demonstrates how to simulate occlusion of virtual content by the real-world face.
*/

import ARKit
import SceneKit

class FaceOcclusionOverlay: NSObject, VirtualContentController {
    
    var contentNode: SCNNode?
    
    var occlusionNode: SCNNode!
    
    /// - Tag: OcclusionMaterial
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let sceneView = renderer as? ARSCNView,
            anchor is ARFaceAnchor else { return nil }

        #if targetEnvironment(simulator)
        #error("ARKit is not supported in iOS Simulator. Connect a physical iOS device and select it as your Xcode run destination, or select Generic iOS Device as a build-only destination.")
        #else
        /*
         Write depth but not color and render before other objects.
         This causes the geometry to occlude other SceneKit content
         while showing the camera view beneath, creating the illusion
         that real-world objects are obscuring virtual 3D objects.
         */
        let faceGeometry = ARSCNFaceGeometry(device: sceneView.device!)!
        faceGeometry.firstMaterial!.colorBufferWriteMask = []
        occlusionNode = SCNNode(geometry: faceGeometry)
        occlusionNode.renderingOrder = -1

        // Add 3D asset positioned to appear as "glasses".
        guard let usdcURL = Bundle.main.url(forResource: "textured_ape", withExtension: "usdz") else { fatalError() }
        let faceOverlayContent = SCNReferenceNode(url: usdcURL)
        faceOverlayContent?.load()

        // Adjust the rotation to make the model face the front
        // Currently loads from the top
        // Thanks ChatGPT
        faceOverlayContent?.eulerAngles.x = -.pi / 2 // Rotate around the X-axis

        // Reduce the size by 50%
        let scale = SCNVector3(0.5, 0.5, 0.5)
        faceOverlayContent?.scale = scale
        
        contentNode = SCNNode()
        contentNode!.addChildNode(occlusionNode)
        contentNode!.addChildNode(faceOverlayContent!)
        #endif
        return contentNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceGeometry = occlusionNode.geometry as? ARSCNFaceGeometry,
            let faceAnchor = anchor as? ARFaceAnchor
            else { return }
        
        faceGeometry.update(from: faceAnchor.geometry)
    }

}
