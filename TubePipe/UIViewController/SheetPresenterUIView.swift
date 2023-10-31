//
//  SheetPresenterUIView.swift
//  TubePipe
//
//  Created by fredrik sundström on 2023-10-30.
//

import SwiftUI

enum SheetPresenterStyle {
    case sheet
    case popover
    case fullScreenCover
    case detents([UISheetPresentationController.Detent])
}

class SheetWrapperController: UIViewController {
    let style: SheetPresenterStyle
    
    init(style: SheetPresenterStyle) {
        self.style = style
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if case let (.detents(detents)) = style, let sheetController = self.presentationController as? UISheetPresentationController {
            sheetController.detents = detents
            sheetController.prefersGrabberVisible = true
        }
    }
}

struct SheetPresenter<Content>: UIViewRepresentable where Content: View {
    let label: String
    let content: () -> Content
    let style: SheetPresenterStyle
    
    init(_ label: String, style: SheetPresenterStyle, @ViewBuilder content: @escaping () -> Content) {
        self.label = label
        self.content = content
        self.style = style
    }
    
    func makeUIView(context: UIViewRepresentableContext<SheetPresenter>) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(label, for: .normal)
        
        let action = UIAction { _ in
            let hostingController = UIHostingController(rootView: content())
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            
            let viewController = SheetWrapperController(style: style)
            switch style {
            case .sheet:
                viewController.modalPresentationStyle = .automatic
            case .popover:
                viewController.modalPresentationStyle = .popover
                viewController.popoverPresentationController?.sourceView = button
            case .fullScreenCover:
                viewController.modalPresentationStyle = .fullScreen
            case .detents:
                viewController.modalPresentationStyle = .automatic
            }
            
            viewController.addChild(hostingController)
            viewController.view.addSubview(hostingController.view)
            
            NSLayoutConstraint.activate([
                hostingController.view.topAnchor.constraint(equalTo: viewController.view.topAnchor),
                hostingController.view.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
                hostingController.view.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
                hostingController.view.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
            ])
            
            hostingController.didMove(toParent: viewController)
            
            if let rootVC = button.window?.rootViewController {
                rootVC.present(viewController, animated: true)
            }
        }
        
        button.addAction(action, for: .touchUpInside)
        return button
    }
    
    func updateUIView(_ uiView: UIButton, context: Context) {}
}
