//
//  File.swift
//  Turing Machine
//
//  Created by Rustam Khakhuk on 04.02.2022.
//

import Foundation
import SwiftUI


struct AlghoritmEditor: View {
    @State var isStatesShow: Bool = false
    @ObservedObject var file: AlghoritmFile
    @ObservedObject var list: AlghoritmsList
    @State var input: String = ""
    @State var inputArray: [String] = ArrayForMachine(array: [])
    
    @State var targetState: Int = 0
    @State var charIndex: Int = 512
    
    @State var isMachinePinned: Bool = false
    
    @State var isActive: Bool = false
    @State var renamePresent: Bool = false
    
    @State var isShowError: Bool = false
    @State var erorText: String = ""
    
    @State var editingMode: Bool = false
    @State var isTimer: Bool = false
    @State var isSharedFile: Bool = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        if file.name == "" {
            Text("")
        } else {
            VStack {
                TuringMachine(input: $inputArray, alghoritm: file.alghoritm, targetState: $targetState, targetIndex: $charIndex, isPinned: $isMachinePinned, isActive: $isActive, isTimerWork: $isTimer)
                if !isActive {
                    EditorInput(file: file, input: $input, inputArray: $inputArray, charIndex: $charIndex)
                } else {
                    StatesTable(alghoritm: file, isPresentProcess: true, targetState: $targetState, targetChar: Binding<String>(get: {
                        return inputArray[charIndex]
                    }, set: { newValue in
                        
                    }), isEditing: $editingMode)
                }
                
                EditorActions(file: file, isShowError: $isShowError, erorText: $erorText, isActive: $isActive, isTimer: $isTimer, isStatesShow: $isStatesShow, charIndex: $charIndex, targetState: $targetState, inputArray: $inputArray, input: $input)
            }
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16))
            .navigationTitle(file.name)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing, content: {
                    Button(action: {
                        isSharedFile = true
                        isStatesShow = true
                        //ShareAlghoritm(file: file)
                        //UIApplication.shared.share
                    }, label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.accentColor)
                    })
                    Menu(content: {
                        Button(action: {
                            renamePresent = true
                            isStatesShow = true
                        }, label: {
                            Text("Rename")
                            Image(systemName: "pencil")
                        })
                        
                        Button(role: .destructive, action: {
                            //isPresenting = true
                            list.alghoritms.remove(at: list.alghoritms.firstIndex(where: { alg in
                                alg === file
                            })!)
                            file.delete()
                            file.name = ""
                            //presentationMode.wrappedValue.dismiss()
                        }, label: {
                            Text("Delete")
                            Image(systemName: "trash")
                        })
                    }, label: {
                        Image(systemName: "pencil.circle")
                    })
                        .disabled(isActive)
                })
                
            }
            .sheet(isPresented: $isStatesShow, onDismiss: {
                if renamePresent {
                    list.objectWillChange.send()
                    renamePresent = false
                } else {
                    file.saveChanges()
                }
            }) {
                if renamePresent {
                    RenameView(name: file.name, file: file)
                } else if isSharedFile {
                    ActivityViewController(activityItems: [FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)[0].appendingPathComponent("\(file.name).tm")])
                } else {
                    StatesEditor(alghoritm: file, isEditing: $editingMode)
                }
            }
            .alert("Error", isPresented: $isShowError, actions: {
                Button("OK") {
                isShowError = false
                }
            }, message: {
                Text(erorText)
            })
        }
    }
}

struct EditorInput: View {
    @ObservedObject var file: AlghoritmFile
    
    @Binding var input: String
    @Binding var inputArray: [String]
    @Binding var charIndex: Int
    
    @FocusState var alphabetFocus: Bool
    @FocusState var inputFocus: Bool

    var body: some View {
        ScrollView(){
            Text("Alphabet:")
                .font(.system(size: 16, weight: .bold, design: .default))
                .foregroundColor(.accentColor)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField("",text: $file.alghoritm.alphabet)
                .frame(height: 42)
                .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(Color(UIColor.secondarySystemBackground))
                )
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0))
                .focused($alphabetFocus)
                .onChange(of: alphabetFocus){ newValue in
                    if !newValue {
                        for i in (0..<file.alghoritm.alphabet.count).reversed() {
                            if file.alghoritm.alphabet.filter({char in char == file.alghoritm.alphabet[file.alghoritm.alphabet.index(file.alghoritm.alphabet.startIndex, offsetBy: i)]}).count != 1 {
                                file.alghoritm.alphabet.remove(at: file.alghoritm.alphabet.index(file.alghoritm.alphabet.startIndex, offsetBy: i))
                            }
                        }
                        file.saveChanges()
                        input = input.filter({char in
                            file.alghoritm.alphabet.contains(char)
                        })
                        inputArray = ArrayForMachine(array: input.map({String($0)}))
                    }
                }
            Text("Input:")
                .font(.system(size: 16, weight: .bold, design: .default))
                .foregroundColor(.accentColor)
                .frame(maxWidth: .infinity, alignment: .leading)
            TextField("",text: $input)
                .frame(height: 42)
                .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(Color(UIColor.secondarySystemBackground))
                )
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0))
                .onSubmit {
                    charIndex = 512
                    input = input.filter({char in
                        "\(file.alghoritm.alphabet)_".contains(char)
                    })
                    inputArray = ArrayForMachine(array: input.map({String($0)}))
                }
                .focused($inputFocus)
                .onChange(of: inputFocus) {newValue in
                    if !newValue {
                        charIndex = 512
                        input = input.filter({char in
                            "\(file.alghoritm.alphabet)_".contains(char)
                        })
                        inputArray = ArrayForMachine(array: input.map({String($0)}))
                    }
                }
        }
    }
}

struct EditorActions: View {
    
    @ObservedObject var file: AlghoritmFile
    
    @Binding var isShowError: Bool
    @Binding var erorText: String

    @Binding var isActive: Bool
    @Binding var isTimer: Bool
    @Binding var isStatesShow: Bool
    @Binding var charIndex: Int
    @Binding var targetState: Int
    @Binding var inputArray: [String]
    @Binding var input: String

    let timer = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(spacing: 8) {
            Button(action: {
                
                withAnimation(.linear(duration: 0.2)) {
                    isActive.toggle()
                }
                
                if !isActive {
                    isTimer = false
                    targetState = 0
                    charIndex = 512
                    inputArray = ArrayForMachine(array: input.map({String($0)}))
                }
                    
            }, label: {
                isActive ? Image(systemName: "pause.fill")
                    .foregroundColor(.white) : Image(systemName: "play.fill")
                    .foregroundColor(.accentColor)
            })
                .frame(width: 42, height: 42, alignment: .center)
                .background(
                    Circle()
                        .foregroundColor(
                            isActive ? .accentColor :
                                Color(uiColor: .secondarySystemBackground)
                        )
                )
            
            if isActive {
                Button(action: {
                    isTimer.toggle()
                }, label: {
                    Image(systemName: "timer")
                        .foregroundColor(isTimer ? .white : .accentColor)
                })
                    .frame(width: 42, height: 42, alignment: .center)
                    .background(
                        Circle()                                    .foregroundColor(isTimer ? .accentColor : Color(uiColor: .secondarySystemBackground))
                    )
                    .onReceive(timer){ _ in
                        if isActive && isTimer {
                            makeStep(isInTimer: true)
                        }
                    }
            }
            
            Button(action: {
                if isActive {
                    //print("hi")
                    makeStep()
                } else {
                    isStatesShow = true
                }
            }, label: {
                Text(isActive ? "Make step" : "States")
                    .frame(height: 42)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .semibold, design: .default))
            })
                .frame(height: 42)
                .frame(maxWidth: .infinity)
                .background(
                    Capsule()
                    //RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(.accentColor)
                )
           // Spacer()
        }
    }
    
    func makeStep(isInTimer: Bool = false) {
        if (isTimer || !isInTimer) && isActive {
            let oldCharIndex = charIndex
            let oldState = targetState
            let oldChar = inputArray[oldCharIndex]
            
            let newState = file.alghoritm.states.first(where: {st in st.number == oldState})!.actions[oldChar]!.state
            
            if file.alghoritm.states.first(where: {st in
                st.number == newState
            }) == nil {
                isShowError = true
                erorText = "At attempt was made to enter state q\(newState), which does not exist."
                isTimer = false
            } else  if !"\(file.alghoritm.alphabet)_".contains(
                file.alghoritm.states.first(where: {st in st.number == oldState})!.actions[oldChar]!.letter
            ) {
                isShowError = true
                erorText = "At attempt was made to replace the current symbol with a symbol \(file.alghoritm.states.first(where: {st in st.number == oldState})!.actions[oldChar]!.letter) what is not in the alphabet."
                isTimer = false
            } else if (charIndex == 0 || charIndex == inputArray.count - 1) {
                isShowError = true
                erorText = "The maximum number of steps allowed has been exceeded."
                isTimer = false
            } else {
                inputArray[oldCharIndex] = file.alghoritm.states.first(where: {st in st.number == oldState})!.actions[inputArray[oldCharIndex]]!.letter
                
                charIndex = file.alghoritm.states.first(where: {st in st.number == oldState})!.actions[oldChar]!.move == "L" ? oldCharIndex - 1 : file.alghoritm.states.first(where: {st in st.number == oldState})!.actions[oldChar]!.move == "R" ? oldCharIndex + 1 : oldCharIndex
                
                targetState = file.alghoritm.states.first(where: {st in st.number == oldState})!.actions[oldChar]!.state
            }
        }
    }
}
