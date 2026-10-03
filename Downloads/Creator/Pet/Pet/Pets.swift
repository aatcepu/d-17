//
//  Pets.swift
//  Pet
//
//  Created by Student on 27/01/2026.
//

import Foundation
import SwiftData

@Model
final class Pet{
    var name: String
    @Attribute(.externalStorage) var photo: Data?
    init(name: String, photo: Data? = nil) {
        self.name = name
        self.photo = photo
    }
}
extension Pet
{
  @MainActor  static var preview: ModelContainer{
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
       let container = try! ModelContainer(for: Pet.self, configurations: configuration)
        fhb
        container.mainContext.insert(Pet(name:"Tommy"))
        container.mainContext.insert(Pet(name:"Honey"))
        container.mainContext.insert(Pet(name:"Rocky"))
        container.mainContext.insert(Pet(name:"Mimi"))
        
        return container
    }
}

//fytfy rty ycdftyf cfccxdv         t
//TLS_DH_RSA_WITH_AES_128_GCM_SHA256
//tfcn zstnxmjnc Bool(from: <#T##any Decoder#>)
