import 'package:flutter/widgets.dart';

/// Simple width-based responsive helpers.
///
/// Breakpoint follows Flutter's own tablet heuristic (shortest side >= 600),
/// so it correctly identifies iPads in both orientations.
extension ResponsiveContext on BuildContext {
  double get _shortestSide => MediaQuery.sizeOf(this).shortestSide;

  bool get isTablet => _shortestSide >= 600;

  /// Scales a phone-baseline font size up for tablets so text doesn't look
  /// tiny on a much larger screen.
  double rs(double base) => isTablet ? base * 1.2 : base;
}
