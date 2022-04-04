//
//  ContentView.swift
//  Knick Knack
//
//  Created by Jordan Huffaker on 2/1/22.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        HomePage()
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}




//@State var filename = "Filename"
//@State var showFileChooser = false
//HStack {
//
//    Text(filename)
//      Button("select File")
//      {
//        let panel = NSOpenPanel()
//        panel.allowsMultipleSelection = false
//        panel.canChooseDirectories = false
//        if panel.runModal() == .OK {
//            self.filename = panel.url?.lastPathComponent ?? "<none>"
//        }
//      }
//}
//.frame(maxWidth: .infinity, maxHeight: .infinity)
