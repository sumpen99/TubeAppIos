//
//  UncommentedCode.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-09-16.
//

/*ref.downloadURL(){ (url, error) in
    //debugLog(object: url)
    onResult?(nil)
}*/

// MARK: - FIREBASE ARRAY-FUNCTIONS
/*func updateCustomerWithNewOrder(_ customer:Customer,orderId:String,onResult:((Error?) -> Void)? = nil){
    let customer = repo.getCustomerDocument(customer.customerId)
    customer.updateData(["orderIds": FieldValue.arrayUnion([orderId])]){ err in
        onResult?(err)
    }
}*/

 

//MARK: MAINVIEW
/*
 @ViewBuilder
 var bottomMenuDefault: some View{
     if firebaseAuth.loggedInAs == .ANONYMOUS_USER{
         TabView(selection: $navigationViewModel.selectedTab) {
             HomeView()
                 .tag(MainTabItem.HOME)
                 .tabItem {
                     Label("Home", systemImage: "house.fill")
                 }
             ModelView()
                 .tag(MainTabItem.MODEL)
                 .tabItem {
                     Label("Model", systemImage: "rotate.3d")
                 }
         }
     }
     else{
         TabView(selection: $navigationViewModel.selectedTab) {
             HomeView()
                 .tag(MainTabItem.HOME)
                 .tabItem {
                     Label("Home", systemImage: "house.fill")
                 }
             ModelView()
                 .tag(MainTabItem.MODEL)
                 .tabItem {
                     Label("Model", systemImage: "rotate.3d")
                 }
             MailboxView()
                 .tag(MainTabItem.INBOX)
                 .tabItem {
                     Label("Inbox", systemImage: "folder")
                 }
            ProfileView()
                 .tag(MainTabItem.PROFILE)
                 .tabItem {
                 Label("Profile", systemImage: "person.fill")
             }
         }
     }
     
 }
 
 var body1: some View{
     bottomMenuDefault
     .customDialog(presentationManager: dialogPresentation)
     .environmentObject(coreDataViewModel)
     .environmentObject(tubeViewModel)
     .environmentObject(navigationViewModel)
     .environmentObject(dialogPresentation)
 }
 
 */

// MARK: BULLETLIST
/*
 func bulletPointList(strings: [String]) -> AttributedString {
     let paragraphStyle = NSMutableParagraphStyle()
     paragraphStyle.headIndent = 15
     paragraphStyle.minimumLineHeight = 22
     paragraphStyle.maximumLineHeight = 22
     paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: 15)]

     let stringAttributes = [
         NSAttributedString.Key.font:  UIFont.systemFont(ofSize: 22),
         NSAttributedString.Key.foregroundColor: UIColor.black,
         NSAttributedString.Key.paragraphStyle: paragraphStyle
     ]

     let string = strings.map({ "•\t\($0)" }).joined(separator: "\n\n")
     let nsAttrString = NSAttributedString(string: string,
                                           attributes: stringAttributes)
     
     return AttributedString(nsAttrString)
 }
 
 Text(bulletPointList(strings:["Help\nHelpHelpHelpHelpHelpHelpHelpHelpHelpHelpHelpHelpHelpHelpHelpHelpHelpHelpHelp","Me","Please"]))
 .lineLimit(nil)
 
 */

/**
 
 enum ErrorCode: RawRepresentable {
     case Generic_Error
     case DB_Error

     var rawValue: (Int, String) {
         switch self {
         case .Generic_Error: return (0, "Unknown")
         case .DB_Error: return (909, "Database")
         }
     }

     init?(rawValue: (Int, String)) {
         switch rawValue {
         case (0, "Unknown"): self = .Generic_Error
         case (909, "Database"): self = .DB_Error
         default: return nil
         }
     }
 }
 
 */

/**
 
 /*ToolbarItem(placement: .principal) {
     Image(systemName: "eye.slash")
 }*/

 */

 
/*
 Large Title
 Title 1
 Title 2
 Title 3
 Headline
 Body
 Callout
 Subhead
 Footnote
 Caption 1
 Caption 2
 
 
if let w = sceneView.scene.rootNode.childNode(withName: name, recursively: true) {
        let (minVec, maxVec) = w.boundingBox
        w.position.x = -25 / 100
        w.position.y = ((maxVec.y - minVec.y) / 2 + minVec.y) / 100
        w.position.z = ((maxVec.z - minVec.z) / 2 + minVec.z) / 100
        w.pivot = SCNMatrix4MakeTranslation(-25, (maxVec.y - minVec.y) / 2 + minVec.y, (maxVec.z - minVec.z) / 2 + minVec.z)
    }
 
 
 func centerPivot(for node: SCNNode) {
     var min = SCNVector3Zero
     var max = SCNVector3Zero
     node.__getBoundingBoxMin(&min, max: &max)
     node.pivot = SCNMatrix4MakeTranslation(
         min.x + (max.x - min.x)/0.5,
         min.y + (max.y - min.y)/0.5,
         min.z + (max.z - min.z)/0.5
     )
 }
 
 let containerNode = SCNNode()
  containerNode.addChildNode(hudNode)
  let roteAction = SCNAction.rotate(by: 3.14, around: SCNVector3(1,0,0), duration: 0)
         hudNode.runAction(roteAction)
 
 
 func set(camera: Camera?) {
     guard let camera else { return }
     
     let action = SCNAction.customAction(duration: 1, action: { _, _ in
         self.view.pointOfView?.position = camera.position
         self.view.pointOfView?.rotation = camera.rotation
         self.view.pointOfView?.orientation = camera.orientation
         self.view.pointOfView?.camera?.fieldOfView = camera.fieldOfView
             })
     self.view.scene?.rootNode.runAction(action)
 }
 
 In the default configuration, SceneKit provides the following controls:
 Pan with one finger to rotate the camera around the scene
 Pan with two fingers to translate the camera on its local xy-plane
 Pan with three fingers vertically to move the camera forward and backward
 Double-tap to switch to the next camera in the scene
 Rotate with two fingers to roll the camera (rotate on the camera node's z-axis)
 Pinch to zoom in or zoom out (change the camera's fieldOfView)
 
 CHANGE FILTER TO TEXTFIELD AND SHOW OPTIONS WHEN TEXTFIELD IS TOUCHED
 
 
 
 import SwiftUI

 final class DialogPresentation: ObservableObject {
     @Published var isPresented = false
     @Published var stopAnimating = false
     @Published var dialogContent: DialogContent?
     var presentedText:String = ""
     
     func show(content: DialogContent?) {
         withAnimation{
             if let presentDialog = content {
                 dialogContent = presentDialog
                 isPresented = true
                 stopAnimating = false
             } else {
                 isPresented = false
                 stopAnimating = true
             }
         }
     }
     
     func closeWithAnimationAfter(time:CGFloat){
         DispatchQueue.main.asyncAfter(deadline: .now()){ [weak self] in
             guard let strongSelf = self else { return }
             strongSelf.stopAnimating = true
             DispatchQueue.main.asyncAfter(deadline: .now()+time){[weak self] in
                 guard let strongSelf = self else { return }
                 strongSelf.isPresented = false
             }
         }
     }
  
 }
 
 
 struct AutoFillProgressView: View {
     @EnvironmentObject var dialogPresentation: DialogPresentation
     let presentedText:String
     var body: some View {
         GeometryReader{ reader in
             let scale = min(reader.size.width,reader.size.height) / 4.0
             let width = min(scale*2.5,250.0)
             let rad = scale / 6.0
             ZStack{
                 Color.white
                 HStack{
                     RingSpinner(size:scale)
                     if dialogPresentation.stopAnimating{
                         Text(dialogPresentation.presentedText).foregroundColor(Color.systemGreen).hLeading()
                     }
                 }
             }
             .frame(width: width,height: scale)
             .cornerRadius(rad)
             .hCenter()
             .vCenter()
         }
     }
         
 }

 struct RingSpinner : View {
     @EnvironmentObject var dialogPresentation: DialogPresentation
     @State var stopAnimating:Bool = false
     @State var pct: Double = 0.0
     let size:CGFloat
     var animation: Animation {
         Animation.easeIn(duration: 1.5).repeatForever(autoreverses: false)
         
     }

     var body: some View {
         ZStack {
             Circle()
                 .trim(from: 0.0, to: 1.0)
                 .stroke(style: StrokeStyle(lineWidth: LINE_WIDTH_ANIMATED, lineCap: .round, lineJoin: .round))
                 .opacity(0.3)
                 .foregroundColor(Color.green)
                 .rotationEffect(.degrees(90.0))
             InnerRing(pct: pct,stopAnimating: stopAnimating).stroke(Color.green, lineWidth: LINE_WIDTH_ANIMATED)
             if dialogPresentation.stopAnimating{
                 Image(systemName: "checkmark")
                 .resizable()
                 .frame(width: size*0.3,height: size*0.3)
                 .foregroundColor(Color.systemGreen)
                 
             }
         }
         .padding()
         .frame(width: size,height: size)
         .hLeading()
         .onChange(of: dialogPresentation.stopAnimating){ isDone in
             if isDone{
                 stopAnimation()
             }
             
         }
         .onAppear(){
             startAnimation()
         }
     }
     
     func startAnimation() {
          withAnimation(animation) {
             self.pct = 1.0
         }
     }
     
     func stopAnimation(){
         withAnimation{
             stopAnimating = true
         }
     }
     
 }

 struct InnerRing : Shape {
     var pct: Double
     var stopAnimating:Bool
     let lagAmmount = 0.35
        
     
     func path(in rect: CGRect) -> Path {
         let end = pct * 360
         var start: Double
       
         if pct > (1 - lagAmmount) {
             start = 360 * (2 * pct - 1.0)
         } else if pct > lagAmmount {
             start = 360 * (pct - lagAmmount)
         } else {
             start = 0
         }
         var p = Path()
         p.addArc(center: CGPoint(x: rect.size.width/2, y: rect.size.width/2),
                  radius: rect.size.width/2,
                  startAngle: Angle(degrees: stopAnimating ? 0.0 : start),
                  endAngle: Angle(degrees: stopAnimating ? 360.0 : end),
                  clockwise: false)

         return p
     }
     
     var animatableData: Double {
         get { return pct }
         set { pct = newValue }
     }
     
 }


*/
