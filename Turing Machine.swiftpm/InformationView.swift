import SwiftUI

struct InformationView: View {
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationView {
            ScrollView(){
                VStack(alignment: .leading,spacing: 24) {
                    Text("\nThis application simulates the Turing machine.\n\nTo create an algorithm, you need to specify the alphabet, input and configure the states of the Turing machine.\n\nRead more about Turing's machine [here](https://en.m.wikipedia.org/wiki/Turing_machine).")
                    
                    Text("Developer")
                        .font(.system(size: 32, weight: .bold, design: .default))
                    Text("Rustam Khakhuk ( Zed Null )\nzed.null@icloud.com")
                    //Text("zed.null@icloud.com")
                }
                .padding([.leading, .trailing], 12)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("About")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing){
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct InformationView_Previews: PreviewProvider {
    static var previews: some View {
        InformationView()
    }
}
