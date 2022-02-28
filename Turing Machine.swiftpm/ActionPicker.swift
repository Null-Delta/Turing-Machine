//
//  File.swift
//  Turing Machine
//
//  Created by Rustam Khakhuk on 26.02.2022.
//

import SwiftUI

struct ActionPicker: View {
    
    //@Environment(\.presentationMode) var presentationMode

    @Binding var popoverIndex: Int

    @State var states = ["q0", "q1", "q2"]
    @State var moves = ["Left", "Nothing", "Right"]
    @State var letters = ["a", "b", "_"]
    
    //@Binding var action: StateAction
    
    @ObservedObject var alghoritm: AlghoritmFile
    @ObservedObject var action: StateAction

    @State var localState: String = ""
    @State var localMove: String = ""
    @State var localLetter: String = ""
    
    init(alghoritm: AlghoritmFile, action: StateAction, index: Binding<Int>) {
        self.alghoritm = alghoritm
        self.action = action
        
        self._states = State(initialValue: alghoritm.alghoritm.states.map({ state in
            "q\(state.number)"
        }))
        
        self._letters = State(initialValue: "\(alghoritm.alghoritm.alphabet)_".map({ char in
            "\(char)"
        }))
        
        _localState = State(initialValue: "q\(action.state)")
        _localMove = State(initialValue: action.move == "N" ? "Nothing" : action.move == "L" ? "Left" : "Right")
        _localLetter = State(initialValue: action.letter)
        
        _popoverIndex = index
        
        //print(action.move)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            MultiWheelPicker(selections: [$localLetter, $localMove, $localState], localSelections: [State(initialValue: ""), State(initialValue: ""), State(initialValue: "")], data: [letters,moves, states])
                .frame(height: 164)
                //.background(Color.red)
                .clipped()
            
            Button("Done") {
                action.objectWillChange.send()
                alghoritm.objectWillChange.send()
                action.state = Int(localState.filter({ char in
                    char != "q"
                }))!
                action.letter = localLetter
                action.move = localMove == "Nothing" ? "N" : localMove == "Left" ? "L" : "R"
                
                popoverIndex = -1
                //presentationMode.wrappedValue.dismiss()
            }
            .frame(height: 48)
            //.background(Color.blue)
            
            Spacer()
        }
        .onAppear {
           
        }
        .background(Color(uiColor: UIColor.systemBackground))
    }
}

struct ActionPicker_Previews: PreviewProvider {
    static var previews: some View {
        ActionPicker(alghoritm: AlghoritmFile(name: ""), action: StateAction(letter: "", move: "", state: 0), index: .constant(0))
            .frame(width: 320, height: 200, alignment: .center)
    }
}

