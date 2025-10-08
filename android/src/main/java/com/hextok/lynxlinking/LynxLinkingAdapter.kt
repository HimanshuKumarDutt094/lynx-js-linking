package com.hextok.lynxlinking

import android.app.Application
import android.content.Context
import android.util.Log

class LynxLinkingAdapter {
  private val TAG = "LynxLinkingAdapter"

  fun init(context: Context) {
    try {
  com.lynx.tasm.LynxEnv.inst().registerModule("LynxLinkingModule", LynxLinkingModule::class.java)
      Log.d(TAG, "LynxLinkingModule registered with LynxEnv")
    } catch (e: Exception) {
      Log.e(TAG, "Failed to register LynxLinkingModule", e)
    }
  }
}
