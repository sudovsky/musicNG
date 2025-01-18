//
//  MakeIdentifiable.swift
//  musicNG
//
//  Created by Max Sudovsky on 17.01.2025.
//

import SwiftUI

//https://stackoverflow.com/questions/57028165/swiftui-scrollview-how-to-modify-content-offset-aka-paging

struct MakeIdentifiable<TModel,TID:Hashable> :  Identifiable {
    var id : TID {
        return idetifier(model)
    }
    let model : TModel
    let idetifier : (TModel) -> TID
}

extension Array {
    func identify<TID: Hashable>(by: @escaping (Element)->TID) -> [MakeIdentifiable<Element, TID>]
    {
        return self.map { MakeIdentifiable.init(model: $0, idetifier: by) }
    }
}
