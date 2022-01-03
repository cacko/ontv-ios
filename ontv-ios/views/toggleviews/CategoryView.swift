import CoreStore
import Kingfisher
import SwiftUI

extension ToggleViews {
  struct CategoryView: View {

    struct CategoryRow: View {
      var stream: ObjectPublisher<Stream>

      func openStream() {
        NotificationCenter.default.post(name: .selectStream, object: stream.object)
      }

      var body: some View {
        Button(action: { openStream() }) {
          HStack(alignment: .top) {
            StreamTitleView.TitleView(stream.icon!) {
              Text(stream.title!)
                .font(Theme.Font.programme)
                .lineLimit(1)
                .truncationMode(.tail)
                .multilineTextAlignment(.leading)
            }
            Spacer()
          }.padding()
        }.buttonStyle(ListButtonStyle())
      }
    }

    @ObservedObject var categoryProvider = StreamStorage.category
    @ObservedObject var player = Player.instance
    @ObservedObject var api = API.Adapter

    private var buttonFont: Font = .system(size: 20, weight: .heavy, design: .monospaced)

    var body: some View {
      if player.contentToggle == .category {
        GeometryReader { geo in
          HStack {
            VStack(alignment: .leading) {
              ContentHeaderView(
                title: player.category?.title ?? "streams",
                icon: ContentToggleIcon.category,
                apiType: .streams
              )
              if api.streamsState == .loading {
                HStack(alignment: .center, spacing: 10) {
                  Text("LOADING").font(Theme.Font.title)
                  ProgressIndicator()
                }
              }
              ScrollViewReader { proxy in
                ScrollingView {
                  ListReader(categoryProvider.list) { snapshot in
                    ForEach(sectionIn: snapshot) { section in
                      ForEach(objectIn: section) { stream in
                        CategoryRow(stream: stream)
                          .id(stream.id)
                          .listHighlight(
                            selectedId: $categoryProvider.selectedId,
                            itemId: stream.id!,
                            highlightPlaying: true
                          )
                      }
                    }
                  }
                }
                .onTapGesture(perform: {})
                .background(.black.opacity(0.8))
                .onAppear {
                  proxy.scrollTo(categoryProvider.selectedId, anchor: .center)
                }
                .navigate(proxy: proxy, id: $categoryProvider.selectedId)
              }
            }
            Spacer(minLength: geo.size.width * 0.5)
          }.contentShape(Rectangle())
            .onTapGesture(perform: {
            player.contentToggle = ContentToggle.none
          })
        }
      }
    }
  }
}
