import CoreStore
import Kingfisher
import SwiftUI

extension ToggleViews {
  struct LivescoreTickerView: View {

    struct TitleTextView: View {
      var text: String
      var body: some View {
        Text(text)
          .font(Theme.Font.Ticker.team)
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

    struct LivescoreItem: View {
      @ObjectState var livescore: ObjectSnapshot<Livescore>?
      private var homeTeam: Schedule.Team!
      private var awayTeam: Schedule.Team!

      init(
        _ objectPublisher: ObjectPublisher<Livescore>
      ) {
        self._livescore = .init(objectPublisher)
        self.homeTeam = Schedule.Team(id: objectPublisher.$home_team ?? "")
        self.awayTeam = Schedule.Team(id: objectPublisher.$away_team ?? "")
      }

      var body: some View {
        if let ls = self.livescore as ObjectSnapshot<Livescore>? {
          HStack(alignment: .center, spacing: 3) {
            BadgeView(icon: homeTeam.icon)
            TitleTextView(text: homeTeam.id)
            Text(ls.$home_score.score)
              .font(Theme.Font.Ticker.score)
              .shadow(color: .black, radius: 1, x: 1, y: 1)
              .foregroundColor(Theme.Color.Font.score)
            HStack(alignment: .center, spacing: 0) {
              Text(ls.$viewStatus)
                .textCase(.uppercase)
                .font(Theme.Font.Ticker.hint)
                .foregroundColor(ls.$inPlay ? .accentColor : .primary)
            }
            Text(ls.$away_score.score)
              .font(Theme.Font.Ticker.score)
              .shadow(color: .black, radius: 1, x: 1, y: 1)
              .foregroundColor(Theme.Color.Font.score)
            TitleTextView(text: awayTeam.id)
            BadgeView(icon: awayTeam.icon)
          }.frame(height: 40, alignment: .center)
            .padding()
        }
      }
    }

    @ObservedObject var liverscoreProvider = LivescoreStorage.events
    @ObservedObject var player = Player.instance
    @ObservedObject var api = API.Adapter
    @State private var forRemoval: Livescore!
    @State private var scrollingTo: String = ""

    private var height: CGFloat = 50.0
    private var buttonFont: Font = .system(size: 20, weight: .heavy, design: .monospaced)

    func onScrollTo(to: String, proxy: ScrollViewProxy) {
      self.scrollingTo = to
      guard self.api.livescoreState == .ready else {
        return
      }
      if forRemoval != nil {
        DispatchQueue.main.async {
          liverscoreProvider.update(self.forRemoval)
          self.forRemoval = nil
        }
      }
      guard forRemoval?.id != to else {
        return
      }

      withAnimation {
        proxy.scrollTo(to, anchor: .leading)
      }
    }

    func toggle(_ object: ObjectPublisher<Livescore>) {
      guard let livescore = object.object as Livescore? else {
        return
      }

      guard self.scrollingTo == livescore.id else {
        DispatchQueue.main.async {
          liverscoreProvider.update(livescore)
        }
        return
      }
      self.forRemoval = livescore
    }

    var body: some View {
      VStack {
        if liverscoreProvider.tickerPosition == .bottom {
          Spacer()
        }
        HStack(alignment: .center) {
          Spacer()
          ScrollViewReader { proxy in
            ScrollingView(.horizontal) {
              ListReader(liverscoreProvider.list) { snapshot in
                ForEach(objectIn: snapshot) { livescore in
                  if livescore.$in_ticker?.bool ?? false {
                    LivescoreItem(livescore)
                      .id(livescore.$id)
                      .onTapGesture(count: 2) { toggle(livescore) }
                      .hideView(state: forRemoval?.id == livescore.$id)
                      .onScoreChange(state: livescore.$score_changed ?? 0 > 0)
                  }
                }
              }
            }
            .onReceive(
              liverscoreProvider.$scrollTo,
              perform: {
                value in onScrollTo(to: value, proxy: proxy)
              }
            )
          }
          .frame(height: height, alignment: .center)
          .onAppear {
            DispatchQueue.main.async {
              LivescoreStorage.enable(.livescoresticker)
            }
          }
          .onDisappear {
            DispatchQueue.main.async {
              LivescoreStorage.disable(.livescoresticker)
            }
          }
          Spacer()
        }.background(Theme.Color.Background.ticker)
        if liverscoreProvider.tickerPosition == .top {
          Spacer()
        }
      }
    }
  }
}
