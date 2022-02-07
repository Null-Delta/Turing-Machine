import SwiftUI

struct RenameView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var name: String = ""
    @ObservedObject var file: AlghoritmFile
    
    @State var isCantRename: Bool = false
    @FocusState var isInFocus: Bool
    var nameList: [String] {
        return getAllAlghoritms()
    }
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("", text: Binding<String>(get: {
                    return name
                }, set: { newValue in
                    name = newValue
                    isCantRename = nameList.contains(name) && name != file.name
                }))
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
                    .padding([.leading, .trailing], 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(Color(uiColor: .secondarySystemBackground))
                    )
                    .padding(EdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16))
                    .focused($isInFocus)
                Text(isCantRename ? "Alghoritm with this name already exist." : "")
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.leading, .trailing], 16)
                Spacer()
            }
            .navigationTitle("Rename")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Done") {
                    if file.name != name {
                        file.name = name
                        file.renameFile()
                    }
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(isCantRename)
            }
        }
    }
}

struct RenameView_Previews: PreviewProvider {
    static var previews: some View {
            RenameView(file: AlghoritmFile(name: "a"))
    }
}
