import SwiftUI

struct ActionSelector: View {
    @State var selectedState: Int
    @State var selectedChar: String
    @ObservedObject var file: AlghoritmFile
    @ObservedObject var action: StateAction
    
    var body: some View {
        VStack(alignment: .leading){
            Text("Symbol replacement:")
            //.font(.system())
            Picker("", selection: $action.letter){
                ForEach(Array("\(file.alghoritm.alphabet)_"), id: \.self){ char in
                    Text(String(char))
                        .tag(String(char))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 42)
            .background(Color(uiColor: UIColor.secondarySystemBackground))
            .cornerRadius(8)
            .pickerStyle(.menu)
            
            Text("Move:")
            Picker("", selection: $action.move){
                Text("Left")
                    .tag("L")
                Text("Nothing")
                    .tag("N")
                Text("Right")
                    .tag("R")
            }
            .frame(maxWidth: .infinity, maxHeight: 42)
            .background(Color(uiColor: UIColor.secondarySystemBackground))
            .cornerRadius(8)
            .pickerStyle(.menu)
            
            Text("Change of state:")
            Picker("", selection: $action.state){
                ForEach(file.alghoritm.states){ st in
                    Text("q\(st.number)")
                        .tag(st.number)
                }
                //Text("Finish")
                //.tag(-1)
            }
            .frame(maxWidth: .infinity, maxHeight: 42)
            .background(Color(uiColor: UIColor.secondarySystemBackground))
            .cornerRadius(8)
            .pickerStyle(.menu)
        }
        .navigationTitle("q\(selectedState):\(selectedChar)")
        .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        Spacer()
    }
}
