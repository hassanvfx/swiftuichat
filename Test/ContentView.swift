//
//  ContentView.swift
//  Test
//
//  Created by Hassan Uriostegui on 9/30/19.
//  Copyright © 2019 Hassan Uriostegui. All rights reserved.
//

import SwiftUI


struct ChatMessage : Hashable {
    var text : String
    var avatar : String
    var mine : Bool
    
    var id : String
    
}

func randomChatMessage()->ChatMessage{
    
    let messages = ["yo","hey","zup","trololo","tada","meh","da","good morning","let's hangout","this is a long text let's see how it looks","😄","🤯","let's hangout let's hangout let's hangout let's hangout let's hangout let's hangout let's hangout "]
    
    let random1 = Int.random(in: 0...messages.count-1)
    let mine = Int.random(in: 0...messages.count-1) % 2 == 0
    
    return ChatMessage(text: messages[random1] , avatar: mine ? "Me" : "You" , mine: mine, id: UUID().uuidString)
    
    
}

struct DetailView: View {
    var body: some View {
        Text("This is the detail view")
    }
}

struct ContentView: View {
    
    @State var inputField = ""
    @State var messages = [randomChatMessage(), randomChatMessage()]
    
    func addMessage(text:String? = nil){
        withAnimation(){
            
            var message = randomChatMessage()
            if let text = text {
                if text.count > 0 {
                    message.text = text
                }
            }
            messages.insert(message, at: 0)
            inputField = ""
        }
    }
    
    var body: some View {
        
        NavigationView{
            KeyboardHost{
                VStack{
                    ScrollView{
                        ForEach(messages, id:\.self){ message in
                            ChatRow(message:message)
                        }
                    }
                    
                    HStack{
                        TextField("Enter your name", text: $inputField)
                        Button("Send"){
                            DispatchQueue.main.async {
                                self.addMessage(text: self.inputField)
                            }
                            
                        }
                    }.padding()
                }
                .navigationBarTitle(Text("SwiftChat (\(messages.count))"))
                .onAppear(){
                    
                    
                    let total = Int.random(in: 1...34)
                    let duration = total > 60 ? 2.0 : total > 34 ? 1.0 : 0.5
                    let delay = duration / Double(total)
                    
                    for index in 0...total{
                        DispatchQueue.main.asyncAfter(deadline: .now() + (delay * Double(index))){
                            self.addMessage()
                        }
                    }
                    
                    
                }
                
            }
            
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ChatRow: View {
    var message : ChatMessage
    @State var loaded = false
    @State var faded = false
    
    func show(){
        withAnimation(.spring( blendDuration: 1)){
            self.loaded = true
        }
    }
    
    func pulse(){
        withAnimation(.linear(duration:0.2)){
              self.faded = false
            self.loaded = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            withAnimation(.linear(duration:0.2)){
            self.faded = true
            }
            self.show()
        }
        
    }
    
    func fontSize() -> Font{
        
        
        if message.text.count > 20 {
            return .headline
        }
        
        if message.text.count > 4 {
            return .title
        }
        
        return .largeTitle
        
    }
    
    var body: some View {
        HStack {
            
            if message.mine {
                Spacer()
            }else{
              Text(message.avatar)
               .bold()
               .opacity(faded ? 0 : 1)
            }
            
    
            Text(message.text)
                .font(fontSize())
                .foregroundColor(.white)
                
                .padding(10)
                .background(message.mine ? Color.purple : Color.blue)
                .cornerRadius(20)
                .opacity(loaded ? 1 : 0)
                .scaleEffect(loaded ? 1 : 0.1 ,anchor: message.mine ? .trailing : .leading)
                .rotation3DEffect(.degrees( loaded ? 0 : message.mine ? -90 :  90), axis: (x: 0, y: 1, z: 0))
                .offset(x: faded ? message.mine ? 40 : -40 : 0, y: 0)
           
            
            if !message.mine {
                Spacer()
            }else{
                  Text(message.avatar)
                               .bold()
                               .opacity(faded ? 0 : 1)
            }
        }
        .padding()
            
        .onAppear(){
            self.show()
            DispatchQueue.main.asyncAfter(deadline: .now() + (self.message.mine ? 0.5 : 1.0)){
                withAnimation(){
                    self.faded = true
                }
            }
        }.onTapGesture {
          
            self.pulse()
        }
    }
}

struct KeyboardHost<Content: View>: View {
    let view: Content

    @State private var keyboardHeight: CGFloat = 0

    private let showPublisher = NotificationCenter.Publisher.init(
        center: .default,
        name: UIResponder.keyboardWillShowNotification
    ).map { (notification) -> CGFloat in
        if let rect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            return rect.size.height
        } else {
            return 0
        }
    }

    private let hidePublisher = NotificationCenter.Publisher.init(
        center: .default,
        name: UIResponder.keyboardWillHideNotification
    ).map {_ -> CGFloat in 0}

    // Like HStack or VStack, the only parameter is the view that this view should layout.
    // (It takes one view rather than the multiple views that Stacks can take)
    init(@ViewBuilder content: () -> Content) {
        view = content()
    }

    var body: some View {
        VStack {
            view
            Rectangle()
                .frame(height: keyboardHeight)
                .animation(.default)
                .foregroundColor(.clear)
        }.onReceive(showPublisher.merge(with: hidePublisher)) { (height) in
            self.keyboardHeight = height
        }
    }
}
