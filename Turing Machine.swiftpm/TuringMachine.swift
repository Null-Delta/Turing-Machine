import SwiftUI

struct TuringMachine: View {
    @Binding var input: [String]
    @ObservedObject var alghoritm: Alghoritm = Alghoritm()
    @Binding var targetState: Int
    @Binding var targetIndex: Int

    @Binding var isPinned: Bool
    @Binding var isActive: Bool
    @Binding var isTimerWork: Bool
    
    var body: some View {
        VStack(spacing: 8){
            TuringRibbon(input: $input, targetIndex: $targetIndex, isPinned: $isPinned, isTimerWork: $isTimerWork)
            
            HStack(alignment: .top){
                Button(action: {
                    isPinned.toggle()
                }, label: {
                    Image(systemName: "pin")
                        .foregroundColor(
                            isPinned ? Color.white : Color.accentColor)
                })
                    .frame(width: 42, height: 42, alignment: .center)
                    .background(
                        Circle()
                            .foregroundColor(
                                isPinned ? .accentColor :
                                    Color(uiColor: .secondarySystemBackground)
                            )
                    )
                
                Spacer()
                Menu(content: {
                    ForEach(alghoritm.states) { state in
                        Button("q\(state.number)"){
                            targetState = state.number
                        }
                    }
                }, label: {
                    Text("state q\(targetState)")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.accentColor)
                })
                .padding([.leading,.trailing], 8)
                .frame(height: 42)
                .frame(width: 104)
                .background(
                    Capsule()
                        .fill(Color(uiColor: .secondarySystemBackground))
                )
                .foregroundColor(Color.white)
                .font(Font.system(size: 16, weight: .medium, design: .default))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 104)
    }
}

struct TuringRibbon: View {
    
    @Binding var input: [String]
    @Binding var targetIndex: Int
    @Binding var isPinned: Bool
    @Binding var isTimerWork: Bool

    var body: some View {
        ZStack(alignment: .top){
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(Color(uiColor: UIColor.secondarySystemBackground))
                .frame(height: 48)
            ScrollViewReader{ value in
                ScrollView(.horizontal, showsIndicators: false){
                    LazyHStack(spacing: 4){
                        ForEach(input.indices, id: \.self){ char in
                            Button(input[char]){
                                targetIndex = char
                                withAnimation{
                                    value.scrollTo(char, anchor: .center)
                                }
                            }
                            .id(char)
                            .font(.system(size: 16, weight: .semibold, design: .default))
                            .frame(width: 24, height: 32)
                            .background(
                                char == targetIndex ?
                                Color.accentColor : Color(uiColor: UIColor.tertiarySystemBackground))
                            .cornerRadius(6)
                            .foregroundColor(
                                char == targetIndex ?
                                Color.white: input[char] == "_" ? Color(uiColor: .systemGray3) : Color(uiColor: UIColor.label)
                            )
                        }
                    }
                    .onChange(of: targetIndex) { newValue in
                        if isTimerWork {
                            withAnimation(.linear(duration: 0.1)){
                                value.scrollTo(targetIndex, anchor: isPinned ? nil : .center)
                            }
                        } else {
                            value.scrollTo(targetIndex, anchor: isPinned ? nil : .center)
                        }
                    }
                    .task {
                        value.scrollTo(targetIndex, anchor: isPinned ? nil : .center)
                    }
                    .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                }
                .frame(height: 48)
            }
        }
    }
}

func ArrayForMachine(array: [String]) -> [String] {
    var space = String(repeating: "_", count: 512).map({String($0)})
    let space2 = space
    space.append(contentsOf: array)
    space.append(contentsOf: space2)
    return space
}
struct TuringMachine_Previews: PreviewProvider {
    static var previews: some View {
        TuringMachine(input: .constant(ArrayForMachine(array: [])), targetState: .constant(0), targetIndex: .constant(512), isPinned: .constant(true), isActive: .constant(false), isTimerWork: .constant(true))
    }
}
