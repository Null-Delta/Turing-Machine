
import SwiftUI
import UIKit

struct MultiWheelPicker: UIViewRepresentable {
    var selections: [Binding<String>]
    var localSelections: [String]
    
    let data: [[String]]
    
    func makeCoordinator() -> MultiWheelPicker.Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: UIViewRepresentableContext<MultiWheelPicker>) -> UIPickerView {
        let picker = UIPickerView()
        picker.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        picker.dataSource = context.coordinator
        picker.delegate = context.coordinator
        
        return picker
    }
    
    func updateUIView(_ view: UIPickerView, context: UIViewRepresentableContext<MultiWheelPicker>) {
        print("hi")
        for comp in selections.indices {
            if selections[comp].wrappedValue != localSelections[comp] {
                if let row = data[comp].firstIndex(of: selections[comp].wrappedValue) {
                    view.selectRow(row, inComponent: comp, animated: false)
                }
            }
        }
    }
    
    class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        var parent: MultiWheelPicker
      
        init(_ pickerView: MultiWheelPicker) {
            parent = pickerView
        }
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return parent.data.count
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return parent.data[component].count
        }
        
        func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
            return 32
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return parent.data[component][row]
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            //parent.selections[component].
            parent.selections[component].wrappedValue = parent.data[component][row]
            parent.localSelections[component] = parent.data[component][row]
            //parent.selections[component].update()

        }
        
        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            var label = UILabel()
            if let v = view as? UILabel { label = v }
            label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            label.text =  parent.data[component][row]
            //label.frame.size.height = 24
            label.textAlignment = .center
            return label
        }
    }
}
