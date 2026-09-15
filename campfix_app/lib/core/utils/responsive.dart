import 'package:flutter/material.dart';

/// Breakpoints per project rule: mobile = bottom nav, tablet/large = rail.
class Responsive {
  Responsive._();

  static const double tabletBreakpoint = 600;
  static const double desktopBreakpoint = 1024;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < tabletBreakpoint;

  static bool isTabletOrLarger(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;
}