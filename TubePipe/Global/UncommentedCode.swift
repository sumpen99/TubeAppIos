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
 

 
 CHANGE FILTER TO TEXTFIELD AND SHOW OPTIONS WHEN TEXTFIELD IS TOUCHED
 

 https:www.freepik.com/free-vector/touch-gestures-icons_1537226.htm#query=swipe%20gesture&position=0&from_view=keyword&track=ais

*/
