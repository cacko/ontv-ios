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
        }
        .buttonStyle(ListButtonStyle())
      }
    }

    @ObservedObject var categoryProvider = StreamStorage.category
    @ObservedObject var player = Player.instance

    private var buttonFont: Font = .system(size: 20, weight: .heavy, design: .monospaced)

    var body: some View {
      VStack(alignment: .leading) {
        ContentHeaderView(
          title: player.category?.title ?? "streams",
          icon: ContentToggleIcon.category
        )
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
          }.onAppear {
            proxy.scrollTo(categoryProvider.selectedId, anchor: .center)
          }
          .navigate(proxy: proxy, id: $categoryProvider.selectedId)
        }
      }
    }
  }
}
