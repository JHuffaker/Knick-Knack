//
//  HomePage.swift
//  Knick Knack
//
//  Created by Jordan Huffaker on 2/14/22.
//

import SwiftUI
import RealityKit

struct BlueButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? Color.blue : Color.white)
            .background(configuration.isPressed ? Color.white : Color.blue)
            .cornerRadius(7)
            .padding()
    }
}

class GameSettings: ObservableObject {
    @Published var score: Double = 0
}

struct HomePage: View {
    @Environment(\.openURL) private var openURL
    @State private var toMessage = false
    @State private var showingSheet = false
    @State private var showingSheet2 = false
    @State private var showingSheet3 = false
    @State var filename = "Filename"
    @StateObject var progress = GameSettings()
    @State private var modelFiles = [URL]()
    @State private var chosenFileName = ""
    @State var messageinfo  =  """
        Choose objects that are static and won’t bend or deform while you’re taking photos. You can move the object between shots in order to photograph all sides, but a soft, articulated, or bendable object that changes shape when you move it can compromise RealityKit’s ability to match landmarks between different images, which may cause Object Capture to fail or produce low-quality results.Avoid objects that are very thin in one dimension, highly reflective, transparent, or translucent. Additionally, objects that are a single, solid color or have a very smooth surface may not provide enough data necessary for the object-creation algorithm to construct a 3D shape. You can draw or paint on the surface of an object to add color or texture, then match the original color or texture on the created 3D object with the material inspector in Xcode’s 3D model viewer or the property inspector in Reality Composer.
    """
    
    var body: some View {
        
        HStack {
            VStack {
                Text("Knick Knack")
                    .font(.system(size: 60))
                    .fontWeight(.bold)
                    .padding(.top, 60)
                Text("Create a 3D Model")
                    .font(.system(size: 30))
                    .padding(.top, 1)

                Button(action: {
                    showingSheet.toggle()
                }) {
                    Text("Start")
                        .font(.title)
                        .fontWeight(.black)
                        .frame(width: 100, height: 50)
                }
                .buttonStyle(BlueButtonStyle())
                .padding(.top, 30)
                .padding(.bottom, 60)
                .sheet(isPresented: $showingSheet, onDismiss: promptFileName) {
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 25, style: .continuous)
                                            .frame(width: 625, height: 300, alignment: .center)
                                            .foregroundColor(.secondary)
                            Text(messageinfo)
                                .font(.title2)
                                .multilineTextAlignment(.center)
                                .frame(width: 600, height: 400)
                        }
                        HStack {
                            Button("Cancel") {
                                showingSheet.toggle()
                            }
                            Button("select File") {
                                let panel = NSOpenPanel()
                                panel.allowsMultipleSelection = true
                                panel.canChooseDirectories = true
                                panel.allowedFileTypes = ["png", "jpg", "jpeg", "HEIC"]
                                if panel.runModal() == .OK {
                                    self.filename = panel.url?.path ?? "<none>"
                                    showingSheet.toggle()
                                }
                            }
                        }
                    }
                    .frame(width: 800, height: 500)
                }
                .sheet(isPresented: $showingSheet3, onDismiss: didDismiss) {
                    Form {
                        Section {
                            TextField("File Name", text: $chosenFileName)
                            Button("Ok") {
                                showingSheet3.toggle()
                            }
                        }
                    }
                }
                .sheet(isPresented: $showingSheet2, onDismiss: john) {
                    ZStack {
                                Color.yellow
                                    .opacity(0.1)
                                    .edgesIgnoringSafeArea(.all)
                                
                                VStack {
                                    ProgressBar()
                                        .frame(width: 150.0, height: 150.0)
                                        .padding(40.0)
                                    Spacer()
                                }
                            }.environmentObject(progress)
                }
            }
            .frame(width: 575)

            List(modelFiles, id: \.self) { pop in
                Section() {
                    Text("\(pop.lastPathComponent)")
                        .onTapGesture {
                            try! Process.run(URL(fileURLWithPath: "/usr/bin/open"), arguments: ["\(getDocumentsDirectory().appendingPathComponent("\(pop.lastPathComponent)"))"],
                            terminationHandler: nil)
                    }
                    Divider()
                }
//                    Button("\(pop.lastPathComponent)") {
//                        try! Process.run(URL(fileURLWithPath: "/usr/bin/open"), arguments: ["\(getDocumentsDirectory().appendingPathComponent("\(pop.lastPathComponent)"))"],
//                        terminationHandler: nil)
//                    }.padding()
            }
            .listStyle(SidebarListStyle())
            .background(Color.primary.opacity(0.15))
        }
        .background(Color.primary.opacity(0.15))
        .frame(width: 800, height: 500)
        .onAppear(perform: john)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func promptFileName() {
        showingSheet3.toggle()
    }
    
    func john() {
        let fm = FileManager.default
        let path = getDocumentsDirectory()

        do {
            let items = try fm.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
            modelFiles = items
//            print(items.count)
//            for item in items {
//                print("Found \(item)")
//            }
        } catch {
            // failed to read directory – bad permissions, perhaps?
        }
    }
    
    func didDismiss() {
        showingSheet2 = true
        let inputFolderURL = URL(fileURLWithPath: self.filename, isDirectory: true)
        
        var config = PhotogrammetrySession.Configuration()

        // Use slower, more sensitive landmark detection.
        config.featureSensitivity = .normal
        // Adjacent images are next to each other.
        config.sampleOrdering = .unordered
        // Object masking is enabled.
//        config.isObjectMaskingEnabled = false

        let session = try! PhotogrammetrySession(input: inputFolderURL, configuration: config)

        Task {
            for try await output in session.outputs {
                switch output {
                case .requestProgress(let request, let fraction):
                    print("Request progress: \(fraction)")
                    progress.score = fraction
                case .requestComplete(let request, let result):
                    if case .modelFile(let url) = result {
                        print("Request result output at \(url).")
                        showingSheet2 = false
                        let executableURL = URL(fileURLWithPath: "/usr/bin/open")
                        try! Process.run(executableURL, arguments: ["\(getDocumentsDirectory().appendingPathComponent("\(chosenFileName).usdz"))"],
                        terminationHandler: nil)
                    }
                case .requestError(let request, let error):
                    print("Error: \(request) error=\(error)")
                case .processingComplete:
                    print("Completed!")
                default:
                    break
                }
            }
        }
        try! session.process(requests: [
            .modelFile(url: getDocumentsDirectory().appendingPathComponent("\(chosenFileName).usdz"), detail: .preview)
        ])
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
    }
}
