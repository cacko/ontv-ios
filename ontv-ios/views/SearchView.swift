//import CoreStore
//import Defaults
//import SwiftUI
//
//extension Notification.Name {
//  static let search_navigate = Notification.Name("search_navigate")
//}
//class SearchTextView: UITextView, NSTextStorageDelegate {
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
//struct MultilineTextView: UIViewRepresentable {
//  typealias UIViewType = SearchTextView
//  
//  @Binding var text: String
//  
//  func makeUIView(context: Self.Context) -> Self.UIViewType {
//    let view = SearchTextView()
//    if let container = view.textContainer {
//      container.maximumNumberOfLines = 1
//    }
//    view.isEditable = true
//    view.isRulerVisible = true
//    view.textStorage?.delegate = view
//    view.font = Theme.Font.searchInput
//    return view
//  }
//  
//  func updateUIView(_ nsView: Self.UIViewType, context: Self.Context) {
//    nsView.string = EPGStorage.search.search
//  }
//}
//
//struct EPGResult: View {
//  private let epg: ObjectPublisher<EPG>
//  private let epgStream: Stream?
//  @ObservedObject var epgSearch = EPGStorage.search
//  @State var background: Color = Theme.Color.Hover.listItem.off
//  init(
//    _ epg: ObjectPublisher<EPG>
//  ) {
//    self.epg = epg
//    self.epgStream = epg.stream as? Stream
//  }
//  
//  func onEPGClick() {
//    NotificationCenter.default.post(name: .selectStream, object: epgStream)
//  }
//  
//  var body: some View {
//    if let stream = epgStream {
//      Button(action: {}) {
//        HStack(alignment: .center, spacing: 0) {
//          Text(epg.startTime!).rotationEffect(.degrees(-90)).font(Theme.Font.searchTime)
//          VStack(alignment: .leading) {
//            HStack(alignment: .center) {
//              Image(systemName: "video.and.waveform")
//                .foregroundColor(.gray)
//              Text("\(epg.title!) - \(stream.name)")
//                .lineLimit(1)
//                .truncationMode(.tail)
//              Spacer()
//            }
//            Text("\(epg.desc!)")
//              .lineLimit(2)
//              .truncationMode(.tail)
//              .font(Theme.Font.desc)
//          }
//          Spacer()
//          StreamTitleView.IconView(stream.icon)
//        }
//        .padding()
//        .liveStateBackground(state: epg.isLive!)
//      }
//      .pressAction { onEPGClick() }
//      .buttonStyle(ListButtonStyle())
//      .buttonStyle(CustomButtonStyle(Theme.Font.result))
//      .background(background)
//      .onChange(
//        of: epgSearch.selectedId,
//        perform: { selectedId in
//          self.background =
//          selectedId == epg.id ? Theme.Color.Hover.listItem.on : Theme.Color.Hover.listItem.off
//        }
//      )
//    }
//  }
//}
//
//struct SearchView: View {
//  @ObservedObject var streamProvider = StreamStorage.search
//  @ObservedObject var epgProvider = EPGStorage.search
//  @ObservedObject var api = API.Adapter
//  
//  @State private var search: String = ""
//  
//  var listproxy: ScrollViewProxy? = nil
//  
//  func onStreamClick(_ stream: ObjectPublisher<Stream>) {
//    NotificationCenter.default.post(name: .selectStream, object: stream.object)
//  }
//  
//  func navigate(proxy: ScrollViewProxy) {
//  }
//  
//  var body: some View {
//    ZStack {
//      VStack(alignment: .leading) {
//        MultilineTextView(text: $search)
//          .textFieldStyle(.squareBorder)
//          .fixedSize(horizontal: false, vertical: true)
//        ScrollViewReader { proxy in
//          ScrollView {
//            VStack(alignment: .leading, spacing: 5) {
//              if api.epgState == .loaded {
//                ListReader(epgProvider.list) { listSnapshot in
//                  ForEach(objectIn: listSnapshot) { obj in
//                    EPGResult(obj)
//                      .contentShape(Rectangle())
//                      .id(obj.id)
//                  }
//                }.navigate(proxy: proxy, id: $epgProvider.selectedId)
//              }
//              ListReader(streamProvider.list) { streamSnapshot in
//                ForEach(objectIn: streamSnapshot) { stream in
//                  Button(action: { onStreamClick(stream) }) {
//                    HStack {
//                      Image(systemName: "tv").foregroundColor(.gray)
//                      Text(stream.title!)
//                        .lineLimit(1)
//                        .truncationMode(.tail)
//                      Spacer()
//                      StreamTitleView.IconView(stream.icon!)
//                      
//                    }.padding()
//                  }
//                  .buttonStyle(CustomButtonStyle(Theme.Font.result))
//                  .contentShape(Rectangle())
//                }
//              }
//            }
//          }.padding(EdgeInsets(top: 55, leading: 10, bottom: 0, trailing: 0))
//        }
//      }.padding()
//      VStack(alignment: .trailing) {
//        Spacer()
//        HStack(alignment: .bottom) {
//          Spacer()
//          ControlItemView(
//            icon: .close,
//            note: Notification.Name.contentToggle,
//            obj: ContentToggle.search,
//            hint: "Close search"
//          )
//        }
//      }.padding()
//    }
//  }
//}
