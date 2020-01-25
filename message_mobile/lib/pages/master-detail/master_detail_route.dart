import 'package:flutter/material.dart';
import 'package:message_mobile/pages/master-detail/master_detail_container.dart';

class DetailRoute<T> extends TransitionRoute<T> with LocalHistoryRoute<T> {
  DetailRoute({@required WidgetBuilder this.builder, RouteSettings settings})
      : super(settings: settings);

  final WidgetBuilder builder;

  @override
  Iterable<OverlayEntry> createOverlayEntries() {
    return [
      OverlayEntry(builder: (context) {
        return Positioned(
          left: isTablet(context) ? kMasterWidth : 0,
          top: 0,
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: isTablet(context)
                ? MediaQuery.of(context).size.width - kMasterWidth
                : MediaQuery.of(context).size.width,
            child: builder(context),
          ),
        );
      })
    ];
  }

  @override
  void install(OverlayEntry insertionPoint) {
    super.install(insertionPoint);
  }

  @override
  bool didPop(T result) {
    final bool returnValue = super.didPop(result);
    assert(returnValue);
    if (finishedWhenPopped) {
      navigator.finalizeRoute(this);
    }
    return returnValue;
  }

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => Duration(milliseconds: 250);
}
