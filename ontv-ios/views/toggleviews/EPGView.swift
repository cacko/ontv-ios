import CoreStore
import SwiftUI

struct EPGRow: View {
  var epg: ObjectPublisher<EPG>
  var color: Color = .white

  init(
    item: ObjectPublisher<EPG>
  ) {
    epg = item
    color = item.isLive! ? Theme.Color.State.live : Theme.Color.State.off
  }

  var body: some View {
    HStack(alignment: .center, spacing: 10) {
      HStack {
        Spacer()
        VStack(alignment: .trailing) {
          Text(epg.title!)
            .font(Theme.Font.programme)
            .lineLimit(3)
            .multilineTextAlignment(.trailing)
          Text(epg.desc!)
            .font(Theme.Font.desc)
            .multilineTextAlignment(.trailing)
        }
      }
      Text(epg.showTime!)
        .rotationEffect(.degrees(90))
        .font(Theme.Font.searchTime)
        .foregroundColor(.mint.opacity(0.8))
    }
    .padding()
    .background(color)
  }
}

extension ToggleViews {
  struct EPGView: View {
    @ObservedObject var epgStorage = EPGStorage.guide

    @ObservedObject var player = Player.instance

    private var buttonFont: Font = .system(size: 20, weight: .heavy, design: .monospaced)

    var body: some View {
      VStack(alignment: .leading, spacing: 0) {
        HStack {
          Spacer()
          if let stream = player.stream {
            StreamTitleView.IconView(stream.icon)
            Text("\(stream.title)")
              .font(Theme.Font.title)
              .lineLimit(1)
              .textCase(.uppercase)
              .fixedSize(horizontal: false, vertical: false)
              .opacity(1)
              .padding()
          }
        }
        .background(Theme.Color.Background.header)
        if epgStorage.state == .notavail {
          VStack(alignment: .trailing) {
            Spacer()
            Text("EPG is not available").font(Theme.Font.result)
            Spacer()
          }
        }
        else {
          ScrollingView {
            ListReader(epgStorage.list) { listSnapshot in
              ForEach(objectIn: listSnapshot) { epg in
                EPGRow(item: epg)
                  .id(epg.id)
              }
            }
          }
        }
      }.onAppear(perform: {
        epgStorage.search = player.stream!.epg_channel_id
      })
      .onChange(
        of: player.stream.epg_channel_id,
        perform: { newid in epgStorage.search = newid }
      )
    }
  }
}
