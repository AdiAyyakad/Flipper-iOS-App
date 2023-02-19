import Core
import Peripheral

import SwiftUI

struct FileManagerEditor: View {
    let path: Peripheral.Path

    @EnvironmentObject var fileManager: RemoteFileManager
    @Environment(\.dismiss) var dismiss

    @State var content: String = ""
    @State var error: String? = nil
    @State var isBusy = false

    var body: some View {
        VStack {
            if let error = error {
                Text(error)
            } else if isBusy {
                ProgressView()
            } else {
                Card {
                    TextEditor(text: $content)
                        .hideScrollBackground()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding(14)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    dismiss()
                }
                Title(path.lastComponent ?? "")
            }
            TrailingToolbarItems {
                NavBarButton {
                    save()
                } label: {
                    Text("Save")
                }
            }
        }
        .padding(.bottom, 16)
        .task {
            await load()
        }
    }

    func load() async {
        do {
            isBusy = true
            defer { isBusy = false }
            content = try await fileManager.readFile(at: path)
        } catch {
            self.error = String(describing: error)
        }
    }

    func save() {
        Task {
            do {
                isBusy = true
                defer { isBusy = false }
                try await fileManager.writeFile(content, at: path)
            } catch {
                self.error = String(describing: error)
            }
        }
    }
}

extension View {
    func hideScrollBackground() -> some View {
        if #available(iOS 16, *) {
            return self
                .scrollContentBackground(.hidden)
        } else {
            UITextView.appearance().backgroundColor = .clear
            return self
        }
    }
}
