import CoreStore
import Defaults
import Kingfisher
import SwiftUI

extension ToggleViews {

  struct TitleTextView: View {
    var text: String
    var body: some View {
      Text(text)
        .font(Theme.Font.scheduleHeader)
        .lineSpacing(30)
        .lineLimit(1)
        .textCase(.uppercase)
        .truncationMode(.tail)
        .multilineTextAlignment(.leading)
    }
  }

  struct BadgeView: View {
    var icon: Icon
    var size: CGFloat! = 30.0
    var body: some View {
      if icon.hasIcon {
        KFImage(icon.url)
          .cacheOriginalImage()
          .setProcessor(
            DownsamplingImageProcessor(size: .init(width: size, height: size))
          ).onSuccess { _ in
            icon.hasIcon = true
          }.onFailure { _ in
            icon.hasIcon = false
          }.resizable()
          .frame(width: icon.hasIcon ? size : 0, height: size, alignment: .center)
      }
    }
  }

  struct TeamView: View {

    var team: Schedule.Team

    var body: some View {
      HStack {
        BadgeView(icon: team.icon)
        TitleTextView(text: team.id)
        Spacer()
      }
    }
  }

  struct ScoreView: View {

    var score: Int

    var body: some View {
      VStack(alignment: .center, spacing: 0) {
        Text(score.score)
          .font(Theme.Font.score)
          .foregroundColor(Theme.Color.Font.score)
          .fixedSize()
          .frame(width: 20)
      }
    }
  }

  struct LivescoreItem: View {
    @ObjectState var livescore: ObjectSnapshot<Livescore>?
    private var homeTeam: Schedule.Team!
    private var awayTeam: Schedule.Team!

    init(
      _ objectPublisher: ObjectPublisher<Livescore>
    ) {
      self._livescore = .init(objectPublisher)
      self.homeTeam = Schedule.Team(id: objectPublisher.home_team ?? "")
      self.awayTeam = Schedule.Team(id: objectPublisher.away_team ?? "")
    }

    var body: some View {
      HStack {
        VStack(alignment: .leading, spacing: 0) {
          Spacer()
          Text(livescore?.$startTime ?? "")
            .rotationEffect(.degrees(-90))
            .lineLimit(1)
            .fixedSize()
            .font(Theme.Font.channel)
          Spacer()
        }.frame(width: 20, alignment: .center)
        VStack(alignment: .center, spacing: 0) {
          HStack(alignment: .center, spacing: 5) {
            TeamView(team: homeTeam)
            Spacer()
            ScoreView(score: livescore?.$home_score ?? -1)
          }
          HStack(alignment: .center, spacing: 5) {
            TeamView(team: awayTeam)
            Spacer()
            ScoreView(score: livescore?.$away_score ?? -1)
          }
        }
      }
    }
  }

  struct LivescoreView: View {

    @ObservedObject var liverscoreProvider = LivescoreStorage.events
    @ObservedObject var player = Player.instance
    @ObservedObject var api = API.Adapter

    private var buttonFont: Font = .system(size: 20, weight: .heavy, design: .monospaced)

    func onTapItem(_ item: ObjectPublisher<Livescore>) {
      guard let ls = item.object as Livescore? else {
        return
      }
      liverscoreProvider.update(ls)
    }

    var body: some View {
      if player.contentToggle == .livescores {
        GeometryReader { geo in
          HStack {
            VStack(alignment: .leading) {
              ContentHeaderView(
                title: "Livescores",
                icon: ContentToggleIcon.livescores,
                apiType: .livescore
              )
              if liverscoreProvider.list.snapshot.count == 0 {
                Text("No scores for the selected leagues")
                  .font(Theme.Font.programme)
                  .padding()
              }
              ScrollingView {
                ListReader(liverscoreProvider.list) { snapshot in
                  ForEach(objectIn: snapshot) { livescore in
                    LivescoreItem(livescore)
                      .padding()
                      .pressAction {
                        onTapItem(livescore)
                      }
                      .onTicker(state: livescore.$in_ticker ?? 0 > 0)
                      .onScoreChange(state: livescore.$score_changed ?? 0 > 0)
                  }
                }
              }.onAppear {
                LivescoreStorage.enable(.livescores)
              }.onDisappear(perform: {
                LivescoreStorage.disable(.livescores)
              })
            }.onTapGesture(perform: {
            })
            .background(.black.opacity(0.8))
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
