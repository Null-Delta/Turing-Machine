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

struct StatesTable: View {
    @ObservedObject var alghoritm: AlghoritmFile
    @State var isPresentProcess: Bool
    
    @Binding var targetState: Int
    @Binding var targetChar: String
    @Binding var isEditing: Bool 

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
                                        alghoritm.alghoritm.states.removeAll(where: {st in
                                            st.number == state.number
                                        })
                                        
                                        alghoritm.objectWillChange.send()
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
                                alghoritm.alghoritm.states.append(AlghoritmState(number: alghoritm.alghoritm.getFreeStateNumber()))
                                alghoritm.alghoritm.states.sort(by: {st1, st2 in
                                    st1.number < st2.number
                                })
                                alghoritm.objectWillChange.send()
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
                                    ForEach(alghoritm.alghoritm.states){ state in
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
                                                    NavigationLink(destination: {
                                                        ActionSelector(
                                                            selectedState: state.number,
                                                            selectedChar: "\(char)",
                                                            file: alghoritm,
                                                            action: state.getAction(char: "\(char)"))
                                                    }, label: {
                                                        Text(state.getAction(char: "\(char)").printInfo(fromState: state.number, withChar: "\(char)"))
                                                            .font(.system(size: 12, weight: .semibold, design: .default))
                                                            .frame(width: 64, height: 32, alignment: .center)
                                                            .background(Color(uiColor: UIColor.secondarySystemBackground))
                                                            .cornerRadius(8)
                                                    })
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
}
