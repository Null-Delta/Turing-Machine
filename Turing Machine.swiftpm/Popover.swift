//  WithPopover.swift
//  PopoverSwiftUI
//

// THANK YOU to this wonderful human:  https://gist.github.com/ccwasden/02cbe25b94eb6e844b43442427127e09

import SwiftUI
 
// -- Source

struct WithPopover<Content: View, PopoverContent: View>: View {
    
    //@Binding var showPopover: Bool?
    
    @Binding var popoverIndex: Int
    var popoverTag: Int
    
    var popoverSize: CGSize? = nil
    var arrowDirections: UIPopoverArrowDirection = [.up, .down]
    let content: () -> Content
    let popoverContent: () -> PopoverContent
    
    var body: some View {
        content()
            .background(
                Wrapper(popoverIndex: $popoverIndex, popoverTag: popoverTag, arrowDirections: arrowDirections, popoverSize: popoverSize, popoverContent: popoverContent)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            )
    }
    
    struct Wrapper<PopoverContent: View> : UIViewControllerRepresentable {
        
        @Binding var popoverIndex: Int
        var popoverTag: Int
        var arrowDirections: UIPopoverArrowDirection
        let popoverSize: CGSize?
        let popoverContent: () -> PopoverContent
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<Wrapper<PopoverContent>>) -> WrapperViewController<PopoverContent> {
            return WrapperViewController(
                popoverSize: popoverSize,
                permittedArrowDirections: arrowDirections,
                popoverContent: popoverContent) {
                self.popoverIndex = -1
            }
        }
        
        func updateUIViewController(_ uiViewController: WrapperViewController<PopoverContent>,
                                    context: UIViewControllerRepresentableContext<Wrapper<PopoverContent>>) {
            uiViewController.updateSize(popoverSize)
            
            if popoverIndex == popoverTag {
                uiViewController.showPopover()
            }
            else {
                uiViewController.hidePopover()
            }
        }
    }
    
    class WrapperViewController<PopoverContent: View>: UIViewController, UIPopoverPresentationControllerDelegate {
        
        var popoverSize: CGSize?
        let permittedArrowDirections: UIPopoverArrowDirection
        let popoverContent: () -> PopoverContent
        let onDismiss: () -> Void
        
        var popoverVC: UIViewController?
        
        required init?(coder: NSCoder) { fatalError("") }
        init(popoverSize: CGSize?,
             permittedArrowDirections: UIPopoverArrowDirection,
             popoverContent: @escaping () -> PopoverContent,
             onDismiss: @escaping() -> Void) {
            self.popoverSize = popoverSize
            self.permittedArrowDirections = permittedArrowDirections
            self.popoverContent = popoverContent
            self.onDismiss = onDismiss
            
            
            super.init(nibName: nil, bundle: nil)
            
            self.isModalInPresentation = true
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
        }
        
        func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
            return .none // this is what forces popovers on iPhone
        }
        
        func showPopover() {
            guard popoverVC == nil else { return }
            let vc = UIHostingController(rootView: popoverContent())
            if let size = popoverSize { vc.preferredContentSize = size }
            vc.modalPresentationStyle = UIModalPresentationStyle.popover
            if let popover = vc.popoverPresentationController {
                popover.sourceView = view
                popover.permittedArrowDirections = self.permittedArrowDirections
                popover.delegate = self
            }
            popoverVC = vc
            self.present(vc, animated: true, completion: nil)
        }
        
        func hidePopover() {
            guard let vc = popoverVC, !vc.isBeingDismissed else { return }
            vc.dismiss(animated: true, completion: nil)
            popoverVC = nil
        }
        
        func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
            popoverVC = nil
            self.onDismiss()
        }
        
        func updateSize(_ size: CGSize?) {
            self.popoverSize = size
            if let vc = popoverVC, let size = size {
                vc.preferredContentSize = size
            }
        }
    }
}
