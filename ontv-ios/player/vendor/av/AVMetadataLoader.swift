//
//  AppleMetadataLoader.swift
//  craptv
//
//  Created by Alex on 31/10/2021.
//

import Foundation
import AVFoundation

extension PlayerAV {
  
  func loadMetadata() {
    for track in self.media.tracks {
      guard let assetTrack = track.assetTrack else {
        continue
      }
      switch assetTrack.mediaType {
      case .video:
        let descriptions = assetTrack.formatDescriptions as! [CMFormatDescription]
        for formatDesc in descriptions {
          guard let desc = formatDesc as CMVideoFormatDescription? else {
            continue
          }
          self.controller.metadata.video = StreamInfo.Video(
            codec:
              "\(desc.mediaSubType.description.trimmingCharacters(in: .punctuationCharacters).uppercased())",
            resolution: CGSize(
              width: Int(desc.dimensions.width),
              height: Int(desc.dimensions.height)
            )
          )
        }
        self.controller.onMetadataLoaded()
        break
      case .audio:
        let descriptions = assetTrack.formatDescriptions as! [CMFormatDescription]
        for formatDesc in descriptions {
          guard let desc = formatDesc as CMAudioFormatDescription? else {
            continue
          }
          
          guard let format = desc.audioStreamBasicDescription as AudioStreamBasicDescription? else {
            continue
          }
          
          self.controller.metadata.audio = StreamInfo.Audio(
            codec:
              "\(desc.mediaSubType.description.trimmingCharacters(in: .punctuationCharacters).uppercased())",
            channels: Int(format.mChannelsPerFrame),
            rate: Int(format.mSampleRate)
          )
        }
        self.controller.metadataState = .loaded
        
        break
      default:
        break
      }
    }
  }
  
}
