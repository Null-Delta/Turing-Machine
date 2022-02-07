//
//  File.swift
//  Turing Machine
//
//  Created by Rustam Khakhuk on 04.02.2022.
//

import SwiftUI

class AlghoritmsList: ObservableObject {
    @Published var alghoritms: [AlghoritmFile] = []
}

struct AlghoritmList: View {
    @ObservedObject var list: AlghoritmsList
    @State var deletingIndex: Int?
    @State var isImport: Bool = false
    @State var importURL: URL? = nil
    
    @State var isErrorShow: Bool = false
    @State var errorText: String = ""
    @State var isInfoOpen: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(list.alghoritms) { item in
                    NavigationLink(destination: {
                        AlghoritmEditor(file: item, list: list)
                    }, label: {
                        Text(item.name)
                    })
                        .isDetailLink(true)
                }
            }
            .onAppear {
                list.objectWillChange.send()
            }
            .listStyle(.sidebar)
            .navigationTitle("Alghoritms")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        isInfoOpen = true
                    }, label: {
                        Image(systemName: "info.circle")
                    })
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Menu(content: {
                        Button(action: {
                            list.alghoritms.append(AlghoritmFile(name: getUnusedName()))
                        }, label: {
                            Text("New alghoritm")
                            Image(systemName: "plus")
                            //.font(.system(size: 16, weight: .semibold, design: .default))
                        })
                        
                        Button(action: {
                            isImport = true
                        }, label: {
                            Text("Import")
                            Image(systemName: "square.and.arrow.down")
                        })
                    }, label: {
                        Image(systemName: "plus")
                    })
                }
            }
        }
        .onAppear {
            list.alghoritms = loadAlghoritms()
        }
        .sheet(isPresented: $isImport, onDismiss: nil) {
            DocumentPicker(filePath: $importURL)
        }
        .sheet(isPresented: $isInfoOpen, onDismiss: nil) {
            InformationView()
        }
        .onChange(of: importURL) {_ in
            if importURL != nil {
                if !importURL!.lastPathComponent.hasSuffix(".tm") {
                    isErrorShow = true
                    errorText = "Uncurrent file type."
                } else {
                    var isDamaged = false
                    var name = importURL!.lastPathComponent
                    name.removeLast(3)
                    
                    let _ = importURL!.startAccessingSecurityScopedResource()
                    do {
                        let _ = try JSONDecoder().decode(Alghoritm.self, from: Data(contentsOf: importURL!))
                    } catch {
                        print(error)
                        isErrorShow = true
                        errorText = "File damaged."
                        isDamaged = true
                    }
                    
                    if !isDamaged {
                        addFile(url: importURL!)
                    }
                    //print("hi")

                    importURL!.stopAccessingSecurityScopedResource()
                }
            }
        }
        .alert(Text("Error"), isPresented: $isErrorShow, actions: {
            Button("OK") {
                
            }
        }, message: {
            Text("\(errorText)")
        })
    }
    
    func addFile(url: URL) {
        if url.lastPathComponent.hasSuffix(".tm") {
            var newName = url.lastPathComponent
            newName.removeLast(3)
            if getAllAlghoritms().contains(newName) {
                for i in 2... {
                    if !getAllAlghoritms().contains("\(newName)(\(i)") {
                        newName = newName + "(\(i))"
                        break
                    }
                }
            }
            try! FileManager.default.copyItem(at: url, to: FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)[0].appendingPathComponent("\(newName).tm"))
            list.alghoritms.append(AlghoritmFile(fromFile: newName))
        }
    }
}

func getAllAlghoritms() -> [String] {
    return try! FileManager.default.contentsOfDirectory(atPath: FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)[0].path).map({value in 
        var newVal = value
        newVal.removeLast(3)
        return newVal
    })
}

func isUnusedName(name: String) -> Bool {
    return !getAllAlghoritms().contains(name)
}

func getUnusedName() -> String {
    let namesList = getAllAlghoritms()
    
    for i in 1... {
        if !namesList.contains("Alghoritm-\(i)") {
            return "Alghoritm-\(i)"
        }
    }
    
    return ""
}

func loadAlghoritms() -> [AlghoritmFile] {
    let names = getAllAlghoritms()
    var result: [AlghoritmFile] = []
    
    names.forEach { name in
        result.append(AlghoritmFile(fromFile: name))
    }
    
    return result
}
