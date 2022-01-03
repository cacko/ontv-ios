import CoreStore
import Defaults
import SwiftUI

enum FocusedState: Hashable {
  case notfocused
  case focused
}

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
  @FocusState private var inputFocusedState: FocusedState?

  @State private var delaySearchTask: DispatchWorkItem!
  let epgSearch = EPGStorage.search

  func getDelaySearchTask() -> DispatchWorkItem {
    if self.delaySearchTask != nil {
      self.delaySearchTask.cancel()
    }
    self.delaySearchTask = DispatchWorkItem {
      guard text.count > 2 else {
        return
      }
      streamProvider.search = text
      epgProvider.search = text
    }
    return self.delaySearchTask
  }

  func textChanged(to value: String) {
    let task = self.getDelaySearchTask()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: task)
  }

  var body: some View {
    HStack {
      TextField("search ...", text: $text.onChange(textChanged))
        .focused($inputFocusedState, equals: .focused)
        .task {
          self.inputFocusedState = .focused
        }
        .background(.clear)
        .autocapitalization(.none)
        .font(Theme.Font.searchInput)
        .textInputAutocapitalization(.never)
        .textCase(.lowercase)
        .onTapGesture {
          self.isEditing = true
        }

      if isEditing {
        Button(action: {
          self.isEditing = false
          self.text = ""
        }) {
          Image(systemName: "xmark")
            .foregroundStyle(.white, .gray)
            .symbolVariant(.circle.fill)
            .imageScale(.medium)
            .symbolRenderingMode(.hierarchical)
            .font(Theme.Font.searchInput)
        }
        .padding(.trailing, 10)
        .transition(.move(edge: .trailing))
      }
    }.padding()
      .buttonStyle(.plain)
  }
}

struct SearchView: View {
  @ObservedObject var streamProvider = StreamStorage.search
  @ObservedObject var epgProvider = EPGStorage.search
  @ObservedObject var api = API.Adapter
  @ObservedObject var player = Player.instance

  @State private var search: String = ""

  func onStreamClick(_ stream: ObjectPublisher<Stream>) {
    NotificationCenter.default.post(name: .selectStream, object: stream.object)
  }

  var body: some View {
    VStack {
      SearchBar(text: $search)
      ScrollingView {
        ListReader(epgProvider.list) { listSnapshot in
          ForEach(objectIn: listSnapshot) { obj in
            EPGResult(obj)
              .id(obj.id)
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
          }
        }
      }
    }.padding()
      .onDisappear {
        player.contentToggle = ContentToggle.none
      }
  }
}
