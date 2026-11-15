import 'package:flutter/widgets.dart';

import 'roster_controller.dart';

/// Exposes the [RosterController] to the widget tree using Flutter's built-in
/// [InheritedNotifier] — no state-management package needed.
class RosterScope extends InheritedNotifier<RosterController> {
  const RosterScope({
    super.key,
    required RosterController controller,
    required super.child,
  }) : super(notifier: controller);

  /// Returns the controller and rebuilds the caller when the squad changes.
  static RosterController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<RosterScope>();
    assert(scope != null, 'No RosterScope found in the widget tree.');
    return scope!.notifier!;
  }

  /// Returns the controller without subscribing to changes (for callbacks).
  static RosterController read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<RosterScope>();
    assert(scope != null, 'No RosterScope found in the widget tree.');
    return scope!.notifier!;
  }
}
