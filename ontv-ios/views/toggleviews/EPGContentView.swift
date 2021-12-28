//
//  EPGContentView.swift
//  EPGContentView
//
//  Created by Alex on 07/10/2021.
//

import CoreStore
import Foundation
import Kingfisher
import SwiftUI

struct AbstractEPGChannel<Content: View>: View {
  let content: Content
  @ObservedObject var player = Player.instance
  private var header: Stream! = nil

  init(
    stream: Stream,
    @ViewBuilder content: () -> Content
  ) {
    self.header = stream
    self.content = content()
  }

  var body: some View {
    Button(action: {}) {
      VStack(alignment: .leading) {
        StreamTitleView.TitleView(header.icon) {
          Text(header.title)
            .font(Theme.Font.title.bold())
            .kerning(-0.5)
            .multilineTextAlignment(.leading)
            .textCase(.uppercase)
            .shadow(color: .accentColor, radius: 1, x: 1, y: 1)
          if header.activity?.favourite ?? 0 > 0 {
            Image(systemName: "suit.heart")
              .symbolVariant(.rectangle.fill)
              .symbolRenderingMode(.hierarchical)
              .font(Theme.Font.title.bold())
          }

        }
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(alignment: .top) {
            content
          }.fixedSize(horizontal: true, vertical: false)
        }
      }.padding()
    }
    .pressAction {
      NotificationCenter.default.post(name: .selectStream, object: header)
    }
    .buttonStyle(ListButtonStyle())
  }
}

struct EPGChannel<Content: View>: View {
  let content: Content
  @ObservedObject var player = Player.instance
  private var header: Stream! = nil

  init(
    section: ListSnapshot<EPG>.SectionInfo,
    @ViewBuilder content: () -> Content
  ) {
    self.header = Stream.findOne(Where<Stream>("epg_channel_id = %s", section.sectionID))
    self.content = content()
  }

  var body: some View {
    if let stream = header as Stream? {
      AbstractEPGChannel(stream: stream) {
        content
      }
    }
  }
}

struct ActivityEPGChannel<Content: View>: View {
  let content: Content
  @ObservedObject var player = Player.instance
  private var header: Stream

  init(
    stream: Stream,
    @ViewBuilder content: () -> Content
  ) {
    self.header = stream
    self.content = content()
  }

  var body: some View {
    AbstractEPGChannel(stream: header) {
      content
    }
  }
}

enum EPGContents {

  enum Row {
    struct Live: View {

      var epg: ObjectPublisher<EPG>

      var body: some View {
        HStack {
          Text(epg.startTime!).font(Theme.Font.searchTime).rotationEffect(.degrees(-90))
          VStack(alignment: .leading) {
            Text(epg.title!)
              .font(Theme.Font.programme)
            Text(epg.desc!)
              .font(Theme.Font.desc)
              .lineLimit(3)
              .truncationMode(.tail)
              .multilineTextAlignment(.leading)
          }
        }
      }
    }

    struct LiveStatic: View {

      var epg: EPG!

      var body: some View {
        HStack {
          Text(epg.startTime).font(Theme.Font.searchTime).rotationEffect(.degrees(-90))
          VStack(alignment: .leading) {
            Text(epg.title)
              .font(Theme.Font.programme)
            Text(epg.desc)
              .font(Theme.Font.desc)
              .lineLimit(3)
              .truncationMode(.tail)
              .multilineTextAlignment(.leading)
          }
        }
      }
    }
  }
}

enum EPGViews {
  struct EPG: View {

    @ObservedObject var player = Player.instance
    @ObservedObject var epgLive = EPGStorage.epglist

    var body: some View {
      if epgLive.state == .loaded {
        ScrollingView {
          ListReader(epgLive.list) { listSnapshot in
            ForEach(sectionIn: listSnapshot) { section in
              EPGChannel(section: section) {
                ForEach(objectIn: section) { epg in
                  EPGContents.Row.Live(epg: epg)
                    .frame(
                      width: Theme.Font.Size.EPGRow.width,
                      height: Theme.Font.Size.EPGRow.height,
                      alignment: .leading
                    )
                    .cornerRadius(10)
                    .liveStateBackground(state: epg.isLive ?? false)
                }
              }
            }
          }
        }
      }
    }
  }

  struct OrderedEpgs: View {

    var epgs: Set<V1.EPG>

    init(
      _ epgs: Set<V1.EPG>
    ) {
      self.epgs = epgs
    }

    var body: some View {
      ForEach(
        epgs.filter { $0.stop.compare(Date()) == .orderedDescending }
          .sorted(by: { (a, b) in a.start.compare(b.start) == .orderedAscending }),
        id: \.self
      ) { epg in
        EPGContents.Row.LiveStatic(epg: epg)
          .frame(
            width: Theme.Font.Size.EPGRow.width,
            height: Theme.Font.Size.EPGRow.height,
            alignment: .leading
          )
          .liveStateBackground(state: epg.isLive)
          .cornerRadius(10)
      }
    }
  }

  struct Activity: View {
    @ObservedObject var player = Player.instance
    @ObservedObject var activityEPG = ActivityStorage.activityepg

    var body: some View {
      ScrollingView {
        ListReader(activityEPG.list) { snapshot in
          ForEach(objectIn: snapshot) { activity in
            ActivityEPGChannel(stream: activity.stream!!) {
              OrderedEpgs(activity.epgs! as Set<V1.EPG>)
            }
          }
        }
      }
    }
  }
}

extension ToggleViews {
  struct EPGContentView: View {
    @ObservedObject var epgLive = EPGStorage.epglist
    @ObservedObject var player = Player.instance

    func scrollToLive(proxy: ScrollViewProxy, item: EPG!) {
      if item != nil {
        proxy.scrollTo(item.id, anchor: .center)
      }
    }

    var body: some View {
      if [.epglist, .activityepg].contains(player.contentToggle) {
        VStack(alignment: .leading, spacing: 0) {
          ContentHeaderView(
            title: player.contentToggle == .epglist ? "TV guide" : "Recent TV guide",
            icon: player.contentToggle == .epglist ? .epglist : .activityepg,
            apiType: .epg
          )
          ZStack {
            if player.contentToggle == .activityepg {
              EPGViews.Activity()
            }

            if player.contentToggle == .epglist {
              EPGViews.EPG()
            }
          }
          if epgLive.state == .loading {
            VStack {
              Spacer()
              HStack(alignment: .center, spacing: 10) {
                Spacer()
                HStack(alignment: .center, spacing: 10) {
                  Text("LOADING").font(Theme.Font.title)
                  ProgressIndicator()
                }
                Spacer()
              }
              Spacer()
            }
          }
        }
      }
    }
  }
}
