/// Method-name constants exchanged between the main app engine and the
/// always-on-top mini recorder window engine.
class MiniIpc {
  MiniIpc._();

  // Main → Mini
  static const stateUpdate = 'state.update';
  static const tagsUpdate = 'tags.update';
  static const lifecycleClose = 'lifecycle.close';

  // Mini → Main
  static const cmdTogglePause = 'cmd.togglePause';
  static const cmdStop = 'cmd.stop';
  static const cmdCancel = 'cmd.cancel';
  static const cmdHideMini = 'cmd.hideMini';
  static const cmdSetSpeakers = 'cmd.setSpeakers';
  static const cmdToggleTag = 'cmd.toggleTag';
  static const cmdBeginDrag = 'cmd.beginDrag';

  /// desktop_multi_window assigns the host engine the windowId 0. New
  /// child engines get sequential ids (1, 2, …).
  static const int mainWindowId = 0;

  /// Mini-window startup arguments role tag.
  static const argRoleMini = 'mini';
}
