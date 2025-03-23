import 'dart:async';
import 'dart:typed_data';
import 'package:device_link/ui/constants/colors.dart';
import 'package:device_link/ui/pages/common_widgets/raised_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class ThumbnailWidget extends StatefulWidget {
  const ThumbnailWidget(
      {super.key,
        required this.source,
        required this.selected,
        required this.onTap
      });
  final DesktopCapturerSource source;
  final bool selected;
  final Function(DesktopCapturerSource) onTap;

  @override
  _ThumbnailWidgetState createState() => _ThumbnailWidgetState();
}

class _ThumbnailWidgetState extends State<ThumbnailWidget> {
  final List<StreamSubscription> _subscriptions = [];
  Uint8List? _thumbnail;
  @override
  void initState() {
    super.initState();
    _subscriptions.add(widget.source.onThumbnailChanged.stream.listen((event) {
      if (mounted) {
        setState(() {
          _thumbnail = event;
        });
      }
    }));
    if (mounted) {
      _subscriptions.add(widget.source.onNameChanged.stream.listen((event) {
        setState(() {});
      }));
    }
  }

  @override
  void deactivate() {
    _subscriptions.forEach((element) {
      element.cancel();
    });
    super.deactivate();
  }

  @override
  void dispose() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              widget.onTap(widget.source);
            },
            child: _thumbnail != null
                ? Align(
              alignment: Alignment.center,
              child: Container(
                decoration: widget.selected
                    ? BoxDecoration(
                  border: Border.all(width: 2, color: tertiaryColor),
                )
                    : null,
                child: Image.memory(
                  _thumbnail!,
                  gaplessPlayback: true,
                  alignment: Alignment.center,
                ),
              ),
            )
                : Container(),
          ),
        ),
        Text(
          widget.source.name,
          style: TextStyle(
            fontSize: 12,
            color: mainTextColor,
            fontWeight: widget.selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class ScreenSelectDialog extends StatefulWidget {
  const ScreenSelectDialog({super.key});

  @override
  State<ScreenSelectDialog> createState() => _ScreenSelectDialogState();
}

class _ScreenSelectDialogState extends State<ScreenSelectDialog> {
  final Map<String, DesktopCapturerSource> _sources = {};
  SourceType _sourceType = SourceType.Screen;
  DesktopCapturerSource? _selected_source;
  final List<StreamSubscription<DesktopCapturerSource>> _subscriptions = [];
  StateSetter? _stateSetter;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 100), () {
      _getSources();
    });

    _subscriptions.add(desktopCapturer.onAdded.stream.listen((source) {
      _sources[source.id] = source;
      if (_stateSetter != null && mounted) {
        _stateSetter!(() {});
      }
    }));

    _subscriptions.add(desktopCapturer.onRemoved.stream.listen((source) {
      _sources.remove(source.id);
      if (_stateSetter != null && mounted) {
        _stateSetter!(() {});
      }
    }));

    _subscriptions.add(desktopCapturer.onThumbnailChanged.stream.listen((source) {
      if (_stateSetter != null && mounted) {
        _stateSetter!(() {});
      }
    }));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stateSetter = null;
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    super.dispose();
  }

  void _ok(context) async {
    _timer?.cancel();
    _stateSetter = null;
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    Navigator.pop<DesktopCapturerSource>(context, _selected_source);
  }

  void _cancel(context) async {
    _timer?.cancel();
    _stateSetter = null;
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    Navigator.pop<DesktopCapturerSource>(context, null);
  }

  Future<void> _getSources() async {
    try {
      var sources = await desktopCapturer.getSources(types: [_sourceType]);
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_stateSetter == null) {
          timer.cancel();
          return;
        }
        desktopCapturer.updateSources(types: [_sourceType]);
      });
      _sources.clear();
      for (var element in sources) {
        _sources[element.id] = element;
      }
      _stateSetter?.call(() {});
      return;
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Material(
        type: MaterialType.transparency,
        child: Center(
          child: SizedBox(
            width: 640,
            height: 560,
            child: GestureDetector(
              behavior: HitTestBehavior.deferToChild,
              onTap: () {
                if (_selected_source != null && _stateSetter != null) {
                  _stateSetter!(() {
                    _selected_source = null;
                  });
                }
              },
              child: RaisedContainer(
                color: raisedColor,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Stack(
                        children: <Widget>[
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Co chcete sdílet?',
                              style:
                              TextStyle(fontSize: 16, color: mainTextColor),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: InkWell(
                              child: const Icon(Icons.close),
                              onTap: () => _cancel(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Dart
                    Expanded(
                      child: StatefulBuilder(
                        builder: (context, setState) {
                          _stateSetter = setState;
                          return Column(
                            children: <Widget>[
                              Expanded(
                                child: DefaultTabController(
                                  length: 2,
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        constraints: const BoxConstraints.expand(height: 24),
                                        child: TabBar(
                                          indicatorColor: tertiaryColor,
                                          indicatorSize: TabBarIndicatorSize.tab,
                                          indicatorWeight: 3,
                                          onTap: (value) => Future.delayed(Duration.zero, () {
                                            _sourceType = value == 0
                                                ? SourceType.Screen
                                                : SourceType.Window;
                                            _getSources();
                                          }),
                                          tabs: const [
                                            Tab(
                                                child: Text(
                                                  'Celou obrazovku',
                                                  style: TextStyle(color: mainTextColor),
                                                )
                                            ),
                                            Tab(
                                                child: Text(
                                                  'Okno',
                                                  style: TextStyle(color: mainTextColor),
                                                )
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Expanded(
                                        child: TabBarView(children: [
                                          Align(
                                            alignment: Alignment.center,
                                            child: GridView.count(
                                              crossAxisSpacing: 8,
                                              crossAxisCount: 2,
                                              children: _sources.entries
                                                  .where((element) =>
                                              element.value.type == SourceType.Screen)
                                                  .map(
                                                    (e) => ThumbnailWidget(
                                                  onTap: (source) {
                                                    setState(() {
                                                      _selected_source = source;
                                                    });
                                                  },
                                                  source: e.value,
                                                  selected: _selected_source?.id == e.value.id,
                                                ),
                                              )
                                                  .toList(),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.center,
                                            child: GridView.count(
                                              crossAxisSpacing: 8,
                                              crossAxisCount: 3,
                                              children: _sources.entries
                                                  .where((element) =>
                                              element.value.type == SourceType.Window)
                                                  .map(
                                                    (e) => ThumbnailWidget(
                                                  onTap: (source) {
                                                    setState(() {
                                                      _selected_source = source;
                                                    });
                                                  },
                                                  source: e.value,
                                                  selected: _selected_source?.id == e.value.id,
                                                ),
                                              )
                                                  .toList(),
                                            ),
                                          ),
                                        ]),
                                      ),
                                      SizedBox(
                                        width: double.infinity,
                                        child: OverflowBar(
                                          children: <Widget>[
                                            MaterialButton(
                                              child: const Text(
                                                'Zrušit',
                                                style: TextStyle(color: mainTextColor),
                                              ),
                                              onPressed: () => _cancel(context),
                                            ),
                                            AbsorbPointer(
                                              absorbing: _selected_source == null,
                                              child: Opacity(
                                                opacity: _selected_source == null ? 0.5 : 1,
                                                child: MaterialButton(
                                                  color: tertiaryColor,
                                                  child: const Text(
                                                    'Sdílet',
                                                    style: TextStyle(color: mainTextColor),
                                                  ),
                                                  onPressed: () => _ok(context),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}