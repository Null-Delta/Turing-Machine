//
//  File.swift
//  Turing Machine
//
//  Created by Rustam Khakhuk on 04.02.2022.
//

import Foundation
import SwiftUI

struct StatesEditor: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var alghoritm: AlghoritmFile
    @State var isSelectorOpen: Bool = false
    @Binding var isEditing: Bool
    
    
    var body: some View {
        NavigationView {
            StatesTable(alghoritm: alghoritm, isPresentProcess: false, targetState: .constant(0), targetChar: .constant("_"), isEditing: $isEditing)
            .navigationTitle("States")
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                Button(isEditing ? "Save" : "Change") {
                    isEditing.toggle()
                }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(isEditing)
                }
            }
            .onAppear{
                alghoritm.objectWillChange.send()
            }
        }
    }
}

class openList: ObservableObject {
    //@Published var binds: [Bool] = .init(repeating: false, count: 1024)
    @Published var newBinds: [act : Bool] = [:]
}

struct act: Hashable {
    var n: Int
    var c: String
}

struct StatesTable: View {
    @ObservedObject var alghoritm: AlghoritmFile
    @State var isPresentProcess: Bool
    
    @Binding var targetState: Int
    @Binding var targetChar: String
    @Binding var isEditing: Bool
    @State var isActionEditing: Bool = false
    
    @ObservedObject var list = openList()
    
    @State var selectedPopover: Int = -1
    //@State var binds: [Int:Binding<Bool>] = [:]

    init(alghoritm: AlghoritmFile, isPresentProcess: Bool, targetState: Binding<Int>, targetChar: Binding<String>, isEditing: Binding<Bool>) {
        self.alghoritm = alghoritm
        self.isPresentProcess = isPresentProcess
        self._targetState = targetState
        self._targetChar = targetChar
        self._isEditing = isEditing
        
//        var binds: [act : Bool] = [:]
//
//        for i in alghoritm.alghoritm.states {
//            for j in "_\(alghoritm.alghoritm.alphabet)" {
//                list.newBinds[act(n: i.number, c: "\(j)")] = false
//            }
//        }
                
        //list.v

        //print(list.newBinds)
    }
    
    var body: some View {
        ScrollViewReader{ stateValue in
            ScrollView(){
                HStack(spacing: 4){
                    VStack(spacing: 4){
                        Text("")
                            .frame(width: 64, height: 32, alignment: .center)
                        ForEach(alghoritm.alghoritm.states){ state in
                            HStack(spacing: 0){
                                Text("q\(state.number)")
                                    .font(.system(size: 16, weight: .bold, design: .default))
                                    .frame(width: 64, height: 32, alignment: .center)
                                if isEditing {
                                    Button(action: {
                                        alghoritm.objectWillChange.send()

                                        alghoritm.alghoritm.states.removeAll(where: {st in
                                            st.number == state.number
                                        })
                                        
                                    }, label: {
                                        Image(systemName: "trash.fill")
                                            .tint(.red)
                                    })
                                        .disabled(state.number == 0)
                                        .frame(width: 32, height: 32, alignment: .center)
                                }
                            }
                            .id(state.number)
                        }
                        if !isPresentProcess && !isEditing {
                            Button("+"){
                                alghoritm.objectWillChange.send()
                                
                                alghoritm.alghoritm.states.append(AlghoritmState(number: alghoritm.alghoritm.getFreeStateNumber()))
                                
                                alghoritm.alghoritm.states.sort(by: {st1, st2 in
                                    st1.number < st2.number
                                })
                                
                                //list.objectWillChange.send()

//                                for i in alghoritm.alghoritm.states {
//                                    for j in "_\(alghoritm.alghoritm.alphabet)" {
//                                        list.newBinds[act(n: i.number, c: "\(j)")] = false
//                                    }
//                                }
//
//                                print(list.newBinds)
                            }
                            .frame(width: 64, height: 32, alignment: .center)
                        }
                    }
                    .frame(width: isEditing ? 96 : 64)
                    ScrollViewReader { charValue in
                        ScrollView(.horizontal){
                            LazyVStack(spacing: 4){
                                if !isEditing {
                                HStack(spacing: 4){
                                    ForEach(Array("\(alghoritm.alghoritm.alphabet)_"), id: \.self){ char in
                                        Text("\(String(char))")
                                            .font(.system(size: 16, weight: .bold, design: .default))
                                            .frame(width: 64, height: 32, alignment: .center)
                                            .cornerRadius(8)
                                    }
                                }
                                    ForEach(alghoritm.alghoritm.states, id: \.id){ state in
                                        LazyHStack(alignment: .top,spacing: 4){
                                            ForEach("\(alghoritm.alghoritm.alphabet)_".map({String($0)}), id: \.self){ char in
                                                if isPresentProcess {
                                                    Text(state.getAction(char: "\(char)").printInfo(fromState: state.number, withChar: "\(char)"))
                                                        .font(.system(size: 12, weight: .semibold, design: .default))
                                                        .frame(width: 64, height: 32, alignment: .center)
                                                        .background(
                                                            state.number == targetState && "\(char)" == targetChar ?
                                                                .accentColor : Color(uiColor: UIColor.secondarySystemBackground)
                                                        )
                                                        .foregroundColor(state.number == targetState && "\(char)" == targetChar ? .white : .accentColor)
                                                        .cornerRadius(8)
                                                } else {
                                                    
                                                    WithPopover(popoverIndex: $selectedPopover, popoverTag: getIndex(n: state.number, char: "\(char)"), popoverSize: CGSize(width: 256, height: 224), content: {
                                                        Button(action: {
                                                            selectedPopover = selectedPopover == -1 ? getIndex(n: state.number, char: "\(char)") : -1
                                                            //print(list.newBinds)
                                                        }, label: {
                                                            Text(state.getAction(char: "\(char)").printInfo(fromState: state.number, withChar: "\(char)"))
                                                                .font(.system(size: 12, weight: .semibold, design: .default))
                                                                .frame(width: 64, height: 32, alignment: .center)
                                                                .background(Color(uiColor: UIColor.secondarySystemBackground))
                                                                .cornerRadius(8)
                                                            }
                                                        )
                                                    }, popoverContent: {
                                                        ActionPicker(alghoritm: alghoritm, action: state.getAction(char: "\(char)"), index: $selectedPopover)

                                                    })
//                                                    WithPopover(showPopover:
//                                                                    $list.newBinds[act(n: state.number, c: "\(char)")],popoverSize: CGSize(width: 256, height: 200), content: {
//
//                                                    }, popoverContent: {
//                                                        ActionPicker()
//                                                        //Text("Popover is Presented")
//                                                    })
                                                    //EmptyView()
                                                
                                                    //PopoverButon(state: state, char: char, list: list)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .onChange(of: targetState) {newValue in
                                withAnimation(.linear(duration: 0.1)) {
                                    stateValue.scrollTo(targetState, anchor: .center)
                                }
                            }
                            .onChange(of: targetChar) {newValue in
                                withAnimation(.linear(duration: 0.1)) {
                                    charValue.scrollTo(targetChar, anchor: .center)
                                }
                            }
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 16))
                        }
                        .ignoresSafeArea()
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: isPresentProcess ? 0 : 36, trailing: 0))
                        .frame(maxHeight: .infinity)
                    }
                }
            }
        }
    }
    
    func getIndex(n: Int, char: String) -> Int {
        var charIndex = -1
        let alph = "_\(alghoritm.alghoritm.alphabet)"

        for i in 0..<alph.count {
            charIndex = String(alph[alph.index(alph.startIndex, offsetBy: i)]) == char ? i : charIndex
        }
        
        let result = n * (alghoritm.alghoritm.alphabet.count + 1) + charIndex;
        
        return result;
    }
}
