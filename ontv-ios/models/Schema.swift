//
//  Schema.swift
//  Schema
//
//  Created by Alex on 13/10/2021.
//

import CoreStore
import Foundation

typealias EPG = V1.EPG
typealias Stream = V1.Stream
typealias Category = V1.Category
typealias Schedule = V1.Schedule
typealias Activity = V1.Activity
typealias Livescore = V1.Livescore
typealias League = V1.League

enum V1 {
}

class Schema {
  class func addStorageAndWait() {
    do {
      CoreStoreDefaults.dataStack = DataStack(
        CoreStoreSchema(
          modelVersion: "V1",
          entities: [
            Entity<V1.Stream>("Stream"),
            Entity<V1.Category>("Category"),
            Entity<V1.Schedule>("Schedule"),
            Entity<V1.EPG>("EPG"),
            Entity<V1.Activity>("Activity"),
            Entity<V1.Livescore>("Livescore"),
            Entity<V1.League>("League"),
          ],
          versionLock: [
            "Activity": [
              0x314a_f1a5_2449_4ef2, 0x5ea1_c944_56a7_5f65, 0x971_4559_1fce_d717,
              0x5b99_2d9f_a3f6_a108,
            ],
            "Category": [
              0x1e66_e5c4_734a_20b3, 0xf33d_9d0a_bab3_2af7, 0xb702_7799_b081_4d2d,
              0x3bcf_75d0_feb5_9842,
            ],
            "EPG": [
              0xb382_dcb3_9c59_663e, 0x3349_38e5_d71a_4ebb, 0xbb85_9462_4f10_d374,
              0x16cb_4120_db9d_551b,
            ],
            "League": [
              0x97d0_384d_c4be_ce1e, 0xad80_72a1_5ebb_15ca, 0xc754_bf9f_daaa_204d,
              0xe84a_9903_3395_98e2,
            ],
            "Livescore": [
              0xc660_e89f_8b4e_e4fe, 0xb402_aaf7_edfb_663d, 0x5e00_b54d_0788_e26e,
              0x6633_f454_c158_e76b,
            ],
            "Schedule": [
              0x1be_1e88_0d66_c07f, 0x8a2b_edac_42cd_65c0, 0x9021_a5d2_3f01_4601,
              0x3a54_fa4c_4cfd_0874,
            ],
            "Stream": [
              0x993_7e74_8575_a81d, 0xecf7_24f7_37fb_f606, 0xce7d_2e1d_7a2c_1981,
              0x5c2b_7ed1_daaa_13ef,
            ],
          ]
        )
      )
      try CoreStoreDefaults.dataStack.addStorageAndWait()
    }
    catch {
      logger.error("\(error.localizedDescription)")
    }
  }
}
