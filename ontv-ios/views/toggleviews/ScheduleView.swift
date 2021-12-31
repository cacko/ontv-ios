import CoreStore
import Introspect
import Kingfisher
import SwiftUI

extension ToggleViews {
  struct ScheduleView: View {

    struct ScheduleTitleTextView: View {
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

    struct ScheduleLivescoreView: View {
      private var livescore: ObjectPublisher<Livescore>!

      init(
        _ eventId: String
      ) {
        guard let objectPublisher = LivescoreStorage.events.get(eventId) else {
          return
        }
        self.livescore = objectPublisher
      }
      var body: some View {
        if let ls = self.livescore as ObjectPublisher<Livescore>? {
          HStack(alignment: .center, spacing: 5) {
            Text(ls.$home_score!.score)
              .font(Theme.Font.score)
              .foregroundColor(Theme.Color.Font.score)
            Text(ls.$viewStatus!)
              .textCase(.uppercase)
              .font(Theme.Font.status)
              .foregroundColor(ls.$inPlay! ? .accentColor : .primary)
            Text(ls.$away_score!.score)
              .font(Theme.Font.score)
              .foregroundColor(Theme.Color.Font.score)
          }
        }
        else {
          Text("vs").textCase(.uppercase).font(Theme.Font.hint)
        }
      }
    }

    struct ScheduleBadgeView: View {
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

    struct ScheduleTitleView<Content: View>: View {
      let content: Content
      let schedule: ObjectPublisher<Schedule>
      private let homeTeam: Schedule.Team!
      private let awayTeam: Schedule.Team!
      private let eventThumb: Schedule.EventThumb!
      private let event_id: String

      init(
        _ schedule: ObjectPublisher<Schedule>,
        @ViewBuilder content: () -> Content
      ) {
        self.content = content()
        self.schedule = schedule
        self.homeTeam = schedule.homeTeam
        self.awayTeam = schedule.awayTeam
        self.eventThumb = schedule.eventThumb
        self.event_id = schedule.object?.event_id.string ?? ""
      }

      var body: some View {
        HStack(alignment: .center, spacing: 5) {
          if homeTeam.isValid, awayTeam.isValid {
            ScheduleBadgeView(icon: homeTeam.icon)
            ScheduleTitleTextView(text: homeTeam.id)
            ScheduleLivescoreView(event_id)
            ScheduleTitleTextView(text: awayTeam.id)
            ScheduleBadgeView(icon: awayTeam.icon)
          }
          else if eventThumb.isValid {
            ScheduleBadgeView(icon: eventThumb.icon)
            content
          }
          else {
            content
          }
        }
      }
    }

    struct ScheduleTime: View {
      var section: ListSnapshot<Schedule>.SectionInfo
      var body: some View {
        if let time = section.first?.object!.timestamp as Date? {
          VStack(alignment: .leading, spacing: 0) {
            Spacer()
            Text(time.HHMM)
              .rotationEffect(.degrees(-90))
              .lineLimit(1)
              .fixedSize()
              .font(Theme.Font.channel)
            Spacer()
          }
          .padding()
          .background(Theme.Color.State.live)
          .frame(width: 80, alignment: .center)
        }
      }
    }

    struct ScheduleHeader: View {
      var schedule: ObjectPublisher<Schedule>

      var body: some View {
        HStack(alignment: .center) {
          ScheduleTitleView(schedule) {
            ScheduleTitleTextView(text: schedule.name!)
          }
          Spacer()
        }
        .padding()
        .background(Theme.Color.Background.headerTitle)
      }
    }

    struct ScheduleStreams: View {
      var schedule: ObjectPublisher<Schedule>
      var streams: [Stream]

      init(
        schedule: ObjectPublisher<Schedule>
      ) {
        self.schedule = schedule
        self.streams = []
        guard let ids = schedule.streams?.split(separator: ",") as NSArray? else {
          return
        }
        guard ids.count > 0 else {
          return
        }
        self.streams = Stream.find(
          Where<Stream>(NSPredicate(format: "stream_id IN %@", ids))
        )
      }

      var body: some View {
        if streams.count > 0 {
          ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
              ForEach(streams, id: \.id) {
                stream in
                ScheduleStream(stream: stream)
                  .id(stream.id)
              }
            }
          }
        }
      }
    }

    struct ScheduleStream: View {
      var stream: Stream

      func openStream() {
        NotificationCenter.default.post(name: .selectStream, object: stream)
      }

      var body: some View {
        Button(action: { openStream() }) {
          HStack(alignment: .top) {
            StreamTitleView.TitleView(stream.icon) {
              Text(stream.title)
                .font(Theme.Font.programme)
                .lineLimit(1)
                .truncationMode(.tail)
                .multilineTextAlignment(.leading)
            }
            Spacer()
          }.padding()
        }
        .buttonStyle(ListButtonStyle()).cornerRadius(10)
      }
    }

    @ObservedObject var scheduleProvider = ScheduleStorage.events
    @ObservedObject var liverscoreProvider = LivescoreStorage.events
    @ObservedObject var player = Player.instance
    @ObservedObject var api = API.Adapter

    private var buttonFont: Font = .system(size: 20, weight: .heavy, design: .monospaced)

    var body: some View {
      if player.contentToggle == .schedule {
        VStack(alignment: .trailing) {
          ContentHeaderView(title: "SportsDB Schedule", icon: ContentToggleIcon.schedule)
          if api.scheduleState == .loading {
            HStack(alignment: .center, spacing: 10) {
              Text("LOADING").font(Theme.Font.title)
              ProgressIndicator()
            }
          }
          ScrollingView {
            ListReader(scheduleProvider.list) { snapshot in
              ForEach(sectionIn: snapshot) { section in
                if liverscoreProvider.timestampInList((section.first?.object!.timestamp)!) {
                  HStack(alignment: .center, spacing: 0) {
                    Section(header: ScheduleTime(section: section)) {
                      LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(objectIn: section) { schedule in
                          LazyVStack(alignment: .leading, spacing: 0) {
                            if liverscoreProvider.eventInList(schedule.$event_id ?? 0) {
                              Section(header: ScheduleHeader(schedule: schedule)) {
                                ScheduleStreams(schedule: schedule)
                              }
                            }
                          }.background(Theme.Color.Background.header)
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }.onAppear {
          scheduleProvider.active = true
          LivescoreStorage.enable(.schedule)
        }.onDisappear(perform: {
          scheduleProvider.active = false
          LivescoreStorage.disable(.schedule)
        })
      }
    }
  }
}
