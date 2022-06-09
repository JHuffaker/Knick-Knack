//
//  HomePage.swift
//  Knick Knack
//
//  Created by Jordan Huffaker on 2/14/22.
//

import SwiftUI
import RealityKit

extension NSTableView {
  open override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()

    backgroundColor = NSColor.clear
    enclosingScrollView!.drawsBackground = false
  }
}

struct StartButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? Color(red: 0.33, green: 0.31, blue: 0.33, opacity: 0.75) : Color(red: 0.33, green: 0.31, blue: 0.33))
            .background(configuration.isPressed ? Color(red: 0.93, green: 0.76, blue: 0.22, opacity: 0.75) : Color(red: 0.93, green: 0.76, blue: 0.22))
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
    @State private var showingInstructions = false
    @State private var showingFileDetails = false
    @State private var showingProgressBar = false
    @State var filename = "Filename"
    @StateObject var progress = GameSettings()
    @State private var modelFiles = [URL]()
    @State private var chosenFileName = ""
    @State private var modelQuality = "preview"
    @State private var showingFileAlert = false
    var qualities = ["preview", "reduced", "medium", "full", "raw"]
    @State var messageinfo  =  """
        Choose objects that are static and won’t bend or deform while you’re taking photos. You can move the object between shots in order to photograph all sides, but a soft, articulated, or bendable object that changes shape when you move it can compromise RealityKit’s ability to match landmarks between different images, which may cause Object Capture to fail or produce low-quality results.Avoid objects that are very thin in one dimension, highly reflective, transparent, or translucent. Additionally, objects that are a single, solid color or have a very smooth surface may not provide enough data necessary for the object-creation algorithm to construct a 3D shape. You can draw or paint on the surface of an object to add color or texture, then match the original color or texture on the created 3D object with the material inspector in Xcode’s 3D model viewer or the property inspector in Reality Composer.
    """
    
    var body: some View {
        
        HStack {
            VStack {
                Text("Knick Knack")
                    .foregroundColor(Color(red: 0.82, green: 0.78, blue: 0.75))
                    .font(.system(size: 60))
                    .fontWeight(.bold)
                    .padding(.top, 60)
                Text("Create a 3D Model")
                    .foregroundColor(Color(red: 0.82, green: 0.78, blue: 0.75))
                    .font(.system(size: 30))
                    .padding(.top, 1)
                Button(action: {
                    showingInstructions.toggle()
                }) {
                    Text("Start")
                        .font(.title)
                        .fontWeight(.black)
                        .frame(width: 100, height: 50)
                }
                .buttonStyle(StartButtonStyle())
                .padding(.top, 30)
                .padding(.bottom, 60)
                Image("AR_Bear3")
                    .resizable()
                    .scaledToFit()
                    .padding(.leading, -250)
                    .padding(.trailing, 50)
                .sheet(isPresented: $showingInstructions) {
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 7, style: .continuous)
                                .frame(width: 625, height: 300, alignment: .center)
                                .foregroundColor(Color(red: 0.00, green: 0.34, blue: 0.49))
                                .background(RoundedRectangle(cornerRadius: 8.0).stroke(Color(red: 0.93, green: 0.76, blue: 0.22), lineWidth: 5))
                            Text(messageinfo)
                                .foregroundColor(Color(red: 0.82, green: 0.78, blue: 0.75))
                                .font(.title2)
                                .multilineTextAlignment(.center)
                                .frame(width: 600, height: 400)
                        }
                        HStack {
                            Button(action: {
                                showingInstructions.toggle()
                            }) {
                                Text("Cancel")
                                    .fontWeight(.black)
                                    .frame(width: 100, height: 50)
                            }
                            .foregroundColor(Color(red: 0.33, green: 0.31, blue: 0.33))
                            .background(Color(red: 0.93, green: 0.76, blue: 0.22))
                            .cornerRadius(5)
                            Button(action: {
                                let panel = NSOpenPanel()
                                panel.allowsMultipleSelection = true
                                panel.canChooseDirectories = true
                                panel.allowedContentTypes = [.png, .image, .jpeg, .heic, .text]
                                if panel.runModal() == .OK {
                                    self.filename = panel.url?.path ?? "<none>"
                                    promptFileName()
                                }
                            }) {
                                Text("select File")
                                    .fontWeight(.black)
                                    .frame(width: 100, height: 50)
                            }
                            .foregroundColor(Color(red: 0.33, green: 0.31, blue: 0.33))
                            .background(Color(red: 0.93, green: 0.76, blue: 0.22, opacity: 1.0))
                            .cornerRadius(5)
                        }
                    }
                    .frame(width: 800, height: 500)
                    .background(LinearGradient(gradient: Gradient(colors: [Color(red: 0.13, green: 0.48, blue: 0.63), Color(red: 0.00, green: 0.34, blue: 0.49)]), startPoint: .leading, endPoint: .trailing))
                }
                .sheet(isPresented: $showingFileDetails) {
                    Form {
                        Section {
                            Spacer()
                            TextField("File Name", text: $chosenFileName)
                            Spacer()
                            Picker("Please choose a quality", selection: $modelQuality) {
                                ForEach(qualities, id: \.self) {
                                    Text($0)
                                }
                            }
                            .pickerStyle(DefaultPickerStyle())
                            Spacer()
                            HStack {
                                Button("Cancel") {
                                    showingFileDetails.toggle()
                                }
                                .foregroundColor(Color(red: 0.33, green: 0.31, blue: 0.33))
                                .background(Color(red: 0.93, green: 0.76, blue: 0.22))
                                .cornerRadius(5)
                                Button("Ok") {
                                    if modelFiles.contains(getDocumentsDirectory().appendingPathComponent("\(chosenFileName).usdz")) {
                                        chosenFileName = ""
                                        showingFileAlert.toggle()
                                    }
                                    else if chosenFileName == "" {
                                        showingFileAlert.toggle()
                                    }
                                    else {
                                        createModel()
                                    }
                                }
                                .foregroundColor(Color(red: 0.33, green: 0.31, blue: 0.33))
                                .background(Color(red: 0.93, green: 0.76, blue: 0.22))
                                .cornerRadius(5)
                            }
                            Spacer()
                        }
                    }.frame(width: 350, height: 200)
                        .padding()
//                        .background(Color(red: 0.13, green: 0.48, blue: 0.63))
                        .background(LinearGradient(gradient: Gradient(colors: [Color(red: 0.13, green: 0.48, blue: 0.63), Color(red: 0.00, green: 0.34, blue: 0.49)]), startPoint: .leading, endPoint: .trailing))
                    .alert(isPresented: $showingFileAlert) {
                        Alert(title: Text("NOPE!"), message: Text("Dumb file name. Try again."), dismissButton: .default(Text("OK")))
                    }
                }
                .sheet(isPresented: $showingProgressBar, onDismiss: getFiles) {
                    ZStack {
                        Color.blue
                            .opacity(0.1)
                            .edgesIgnoringSafeArea(.all)
                        
                        VStack {
                            ProgressBar()
                                .frame(width: 150.0, height: 150.0)
                                .padding(40.0)
                            Spacer()
                        }
                    }
                    .environmentObject(progress)
                    .background(LinearGradient(gradient: Gradient(colors: [Color(red: 0.13, green: 0.48, blue: 0.63), Color(red: 0.00, green: 0.34, blue: 0.49)]), startPoint: .leading, endPoint: .trailing))
                }
            }
            .frame(width: 575)
            
            ZStack {
                Color(red: 0.13, green: 0.48, blue: 0.63)
                VStack {
                    Text("Model Files")
                        .foregroundColor(Color(red: 0.82, green: 0.78, blue: 0.75))
                        .font(.system(size: 30))
                        .fontWeight(.bold)
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                    Divider()
                        .frame(width: 200, height: 0.5)
                        .background(Color(red: 0.82, green: 0.78, blue: 0.75))
                    List(modelFiles, id: \.self) { pop in
                        ZStack {
                            Rectangle()
                                .frame(width: 180, height: 40)
                                .foregroundColor(Color(red: 0.93, green: 0.76, blue: 0.22))
                                .cornerRadius(7)
                            Text("\(pop.lastPathComponent)")
                                .foregroundColor(Color(red: 0.33, green: 0.31, blue: 0.33))
                        }
                        .onTapGesture {
                            try! Process.run(URL(fileURLWithPath: "/usr/bin/open"), arguments: ["-a", "Preview",  "\(getDocumentsDirectory().appendingPathComponent("\(pop.lastPathComponent)"))"],
                            terminationHandler: nil)
                        }
                        .contextMenu {
                            Button {
                                deleteModel(modelPath: getDocumentsDirectory().appendingPathComponent("\(pop.lastPathComponent)"))
                            } label: {
                                Text("Delete")
                            }
                        }
                    }
                }
            }
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color(red: 0.13, green: 0.48, blue: 0.63), Color(red: 0.00, green: 0.34, blue: 0.49)]), startPoint: .leading, endPoint: .trailing))
        .frame(width: 800, height: 500)
        .onAppear(perform: getFiles)
    }
    
    
    func deleteModel(modelPath: URL) {
        let fm = FileManager.default
        do {
            try fm.removeItem(at: modelPath)
            getFiles()
        } catch {
            print("Could not successfully delete \(modelPath)")
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func promptFileName() {
        showingInstructions.toggle()
        showingFileDetails.toggle()
    }
    
    func getFiles() {
        let fm = FileManager.default
        let path = getDocumentsDirectory()

        do {
            let items = try fm.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
            modelFiles = items
        } catch {
            print("Failed to receive files")
        }
    }
    
    func createModel() {
        showingFileDetails.toggle()
        showingProgressBar = true
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
                case .requestProgress(_, let fraction):
                    print("Request progress: \(fraction)")
                    progress.score = fraction
                case .requestComplete(_, let result):
                    if case .modelFile(let url) = result {
                        print("Request result output at \(url).")
                        showingProgressBar = false
                        let executableURL = URL(fileURLWithPath: "/usr/bin/open")
                        try! Process.run(executableURL, arguments: ["-a", "Preview",  "\(getDocumentsDirectory().appendingPathComponent("\(chosenFileName).usdz"))"],
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
        
        if modelQuality == "preview" {
            try! session.process(requests: [
                .modelFile(url: getDocumentsDirectory().appendingPathComponent("\(chosenFileName).usdz"), detail: .preview)
            ])
        }
        else if modelQuality == "reduced" {
            try! session.process(requests: [
                .modelFile(url: getDocumentsDirectory().appendingPathComponent("\(chosenFileName).usdz"), detail: .reduced)
            ])
        }
        else if modelQuality == "medium" {
            try! session.process(requests: [
                .modelFile(url: getDocumentsDirectory().appendingPathComponent("\(chosenFileName).usdz"), detail: .medium)
            ])
        }
        else if modelQuality == "full" {
            try! session.process(requests: [
                .modelFile(url: getDocumentsDirectory().appendingPathComponent("\(chosenFileName).usdz"), detail: .full)
            ])
        }
        else if modelQuality == "raw" {
            try! session.process(requests: [
                .modelFile(url: getDocumentsDirectory().appendingPathComponent("\(chosenFileName).usdz"), detail: .raw)
            ])
        }
        
    }
    
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
    }
}
