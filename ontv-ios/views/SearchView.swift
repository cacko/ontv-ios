import CoreStore
import Defaults
import SwiftUI

extension Notification.Name {
  static let search_navigate = Notification.Name("search_navigate")
}

struct EPGResult: View {
  private let epg: ObjectPublisher<EPG>
  private let epgStream: Stream?
  @ObservedObject var epgSearch = EPGStorage.search
  @State var background: Color = Theme.Color.Hover.listItem.off
  init(
    _ epg: ObjectPublisher<EPG>
  ) {
    self.epg = epg
    self.epgStream = epg.stream as? Stream
  }

  func onEPGClick() {
    NotificationCenter.default.post(name: .selectStream, object: epgStream)
  }

  var body: some View {
    if let stream = epgStream {
      Button(action: {}) {
        HStack(alignment: .center, spacing: 0) {
          Text(epg.startTime!).rotationEffect(.degrees(-90)).font(Theme.Font.searchTime)
          VStack(alignment: .leading) {
            HStack(alignment: .center) {
              Image(systemName: "video.and.waveform")
                .foregroundColor(.gray)
              Text("\(epg.title!) - \(stream.name)")
                .lineLimit(1)
                .truncationMode(.tail)
              Spacer()
            }
            Text("\(epg.desc!)")
              .lineLimit(2)
              .truncationMode(.tail)
              .font(Theme.Font.desc)
          }
          Spacer()
          StreamTitleView.IconView(stream.icon)
        }
        .padding()
        .liveStateBackground(state: epg.isLive!)
      }
      .pressAction { onEPGClick() }
      .buttonStyle(ListButtonStyle())
      .buttonStyle(CustomButtonStyle(Theme.Font.result))
      .background(background)
      .onChange(
        of: epgSearch.selectedId,
        perform: { selectedId in
          self.background =
            selectedId == epg.id ? Theme.Color.Hover.listItem.on : Theme.Color.Hover.listItem.off
        }
      )
    }
  }
}

//class SearchTextView: , storag {
//
//  var delaySearchTask: DispatchWorkItem!
//  let epgSearch = EPGStorage.search
//
//  private func getDelaySearchTask() -> DispatchWorkItem {
//    if self.delaySearchTask != nil {
//      self.delaySearchTask.cancel()
//    }
//    self.delaySearchTask = DispatchWorkItem {
//      if let text = self.textStorage?.string {
//        StreamStorage.search.search = text
//        EPGStorage.search.search = text
//        return
//      }
//      NotificationCenter.default.post(name: .contentToggle, object: ContentToggle.search)
//    }
//    return self.delaySearchTask
//  }
//
//  override func textStorageDidProcessEditing(_ notification: Notification) {
//    let task = self.getDelaySearchTask()
//    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: task)
//  }
//
//  override func cancelOperation(_ sender: Any?) {
//    guard let storage = self.textStorage else {
//      return NotificationCenter.default.post(
//        name: .contentToggle,
//        object: ContentToggle.search
//      )
//    }
//    guard storage.string.count > 0 else {
//      return NotificationCenter.default.post(
//        name: .contentToggle,
//        object: ContentToggle.search
//      )
//    }
//
//    self.selectAll(nil)
//    self.delete(nil)
//  }
//
//}
//
//
//class SearchTextIput: UITextField {
//
//
//
//}
//
//struct TextSearchView: UIViewRepresentable {
//
//  typealias UIViewType = UITextField
//
//  @Binding var text: String
//
//  func makeUIView(context: Context) -> UITextField {
//    let view = SearchTextIput()
//    view.becomeFirstResponder()
//    view.backgroundColor = .red
//
//    //    if let container = view.textContainer {
//    //      container.maximumNumberOfLines = 1
//    //    }
//    //    view.isEditable = true
//    //    view.isRulerVisible = true
//    //    view.textStorage?.delegate = view
//    //    view.font = Theme.Font.searchInput
//    //
//    //
//    //
//    return view
//    //
//  }
//
//  func updateUIView(_ nsView: Self.UIViewType, context: Self.Context) {
//  }
//}

extension Binding {
  func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
    Binding(
      get: { self.wrappedValue },
      set: { newValue in
        self.wrappedValue = newValue
        handler(newValue)
      }
    )
  }
}

struct SearchBar: View {
  @Binding var text: String
  @ObservedObject var streamProvider = StreamStorage.search
  @ObservedObject var epgProvider = EPGStorage.search
  @State private var isEditing = false

  @State private var delaySearchTask: DispatchWorkItem!
  let epgSearch = EPGStorage.search

  func getDelaySearchTask() -> DispatchWorkItem {
    if self.delaySearchTask != nil {
      self.delaySearchTask.cancel()
    }
    self.delaySearchTask = DispatchWorkItem {
      guard text.count == 0 else {
        DispatchQueue.main.async {
          streamProvider.search = text
          epgProvider.search = text
          logger.debug(">> search fired \(text)")
        }

        return
      }
      NotificationCenter.default.post(name: .contentToggle, object: ContentToggle.search)
    }
    return self.delaySearchTask
  }

  func textChanged(to value: String) {
    print("\(text)")
    let task = self.getDelaySearchTask()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: task)
  }

  var body: some View {
    HStack {
      TextField("Search ...", text: $text.onChange(textChanged))
        .padding(7)
        //        .padding(.horizontal, 25)
        .background(.background)
        .foregroundColor(.primary)
        //        .cornerRadius(8)
        //        .padding(.horizontal, 10)
        //        .fixedSize(horizontal: true, vertical: true)
        //        .border(.red, width: 1)
        .font(Theme.Font.searchInput)
        .onTapGesture {
          self.isEditing = true
        }

      if isEditing {
        Button(action: {
          self.isEditing = false
          self.text = ""
        }) {
          Text("Cancel")
        }
        .padding(.trailing, 10)
        .transition(.move(edge: .trailing))
      }
    }
  }
}

struct SearchView: View {
  @ObservedObject var streamProvider = StreamStorage.search
  @ObservedObject var epgProvider = EPGStorage.search
  @ObservedObject var api = API.Adapter

  @State private var search: String = ""

  var listproxy: ScrollViewProxy? = nil

  func onStreamClick(_ stream: ObjectPublisher<Stream>) {
    NotificationCenter.default.post(name: .selectStream, object: stream.object)
  }

  func navigate(proxy: ScrollViewProxy) {
  }

  var body: some View {
    VStack {
      SearchBar(text: $search)
      ScrollingView {
        VStack(alignment: .leading, spacing: 5) {
          if api.epgState == .loaded {
            ListReader(epgProvider.list) { listSnapshot in
              ForEach(objectIn: listSnapshot) { obj in
                EPGResult(obj)
                  .contentShape(Rectangle())
                  .id(obj.id)
              }
            }
          }
          ListReader(streamProvider.list) { streamSnapshot in
            ForEach(objectIn: streamSnapshot) { stream in
              Button(action: { onStreamClick(stream) }) {
                HStack {
                  Image(systemName: "tv").foregroundColor(.gray)
                  Text(stream.title!)
                    .lineLimit(1)
                    .truncationMode(.tail)
                  Spacer()
                  StreamTitleView.IconView(stream.icon!)

                }.padding()
              }
              .buttonStyle(CustomButtonStyle(Theme.Font.result))
              .contentShape(Rectangle())
            }
          }
        }
      }
    }
  }
}
