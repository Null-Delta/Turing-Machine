//
//  File.swift
//  Turing Machine
//
//  Created by Rustam Khakhuk on 04.02.2022.
//

import Foundation
import SwiftUI

class Alghoritm: ObservableObject, Codable {
    @Published var alphabet: String
    @Published var states: [AlghoritmState]
    
    enum ChildKeys: CodingKey {
        case alphabet, states
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ChildKeys.self)
        self.alphabet = try container.decode(String.self, forKey: .alphabet)
        self.states = try container.decodeIfPresent([AlghoritmState].self, forKey: .states) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ChildKeys.self)
        try container.encode(self.alphabet, forKey: .alphabet)
        try container.encodeIfPresent(self.states, forKey: .states)
    }
    
    init(){
        alphabet = ""
        states = [AlghoritmState(number: 0)]
    }
    
    func getFreeStateNumber() -> Int {
        for i in 0... {
            if !states.contains(where: {st in st.number == i}) {
                return i
            }
        }
        return -1
    }
    
    func getAction(num: Int, char: String) -> StateAction {
        let index = states.firstIndex(where: {st in
            st.number == num
        })!
        
        if states[index].actions[char] == nil {
            states[index].actions[char] = StateAction(letter: char, move: "N", state: num)
        }
        
        return states[index].actions[char]!
    }
}

class AlghoritmState: Identifiable, Codable {
    var actions: [String: StateAction]
    var number: Int
    var id = UUID()
    
    enum ChildKeys: CodingKey {
        case actions, number
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ChildKeys.self)
        self.actions = try container.decode([String: StateAction].self, forKey: .actions)
        self.number = try container.decodeIfPresent(Int.self, forKey: .number) ?? -1
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ChildKeys.self)
        try container.encode(self.actions, forKey: .actions)
        try container.encodeIfPresent(self.number, forKey: .number)
    }
    
    init(number: Int){
        self.number = number
        actions = [:]
    }
    
    func getAction(char: String) -> StateAction {
        if actions[char] == nil {
            actions[char] = StateAction(letter: char, move: "N", state: number)
        }
        
        return actions[char]!
    }
}

class StateAction: ObservableObject, Codable {
    @Published var letter: String
    @Published var move: String
    @Published var state: Int
    static var empty: StateAction = StateAction(letter: "", move: "", state: -1)
    
    enum ChildKeys: CodingKey {
        case letter, move, state
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ChildKeys.self)
        self.letter = try container.decode(String.self, forKey: .letter)
        self.move = try container.decode(String.self, forKey: .move)
        self.state = try container.decode(Int.self, forKey: .state)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ChildKeys.self)
        try container.encode(self.letter, forKey: .letter)
        try container.encode(self.move, forKey: .move)
        try container.encodeIfPresent(self.state, forKey: .state)
    }
    
    init(letter l: String, move m: String, state s: Int){
        letter = l
        move = m
        state = s
    }
    
    func getMoveArrow() -> String {
        switch move {
        case "L":
            return "←"
        case "R":
            return "→"
        case "N":
            return "↓"
        default:
            return ""
        }
    }
    func printInfo() -> String {
        return "\(letter) \(getMoveArrow()) \(state == -1 ? "!" : "q\(state)")"
    }
    
    func printInfo(fromState: Int, withChar: String) -> String {
        if letter == withChar && fromState == state {
            return getMoveArrow()
        } else {
            return "\(letter) \(getMoveArrow()) \(state == -1 ? "!" : "q\(state)")"
        }
    }
}

class AlghoritmFile: Identifiable, ObservableObject {
    let id = UUID()
    @Published var name: String
    @Published var alghoritm: Alghoritm
    
    private var oldName: String
    
    init(name: String) {
        self.name = name
        oldName = name
        alghoritm = Alghoritm()
        
        try! JSONEncoder().encode(alghoritm).write(to: FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)[0].appendingPathComponent("\(name).tm"))
    }
    
    init(fromFile: String) {
        name = fromFile
        oldName = fromFile
        alghoritm = Alghoritm()
        do {
            alghoritm = try JSONDecoder().decode(Alghoritm.self, from: Data(contentsOf: FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)[0].appendingPathComponent("\(fromFile).tm")))
        } catch {
            alghoritm = Alghoritm()
        }
    }
    
    func renameFile() {
        try! FileManager.default.moveItem(at: FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)[0].appendingPathComponent("\(oldName).tm"), to: FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)[0].appendingPathComponent("\(name).tm"))
        
        oldName = name
    }
    
    func backName() {
        name = oldName
    }
    
    func saveChanges() {
        try! JSONEncoder().encode(alghoritm).write(to: FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)[0].appendingPathComponent("\(name).tm"))
    }
    
    func delete() {
        try! FileManager.default.removeItem(at: FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)[0].appendingPathComponent("\(name).tm"))
    }
}
