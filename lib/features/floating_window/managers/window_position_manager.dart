import 'dart:developer';
import 'dart:ui';

class WindowPositionManager {
  static const double verticalPadding = 10.0; // Padding to vertical space
  static const double horizontalPadding = 10.0; // Padding to horizontal space

  static const double horizontalBoundaryPadding = 20.0; // Padding to prevent horizontal overflow

  // Singleton implementation
  WindowPositionManager._();

  static final WindowPositionManager instance = WindowPositionManager._();

  List<Offset> windowPositionRatios = []; // Store positions as ratios

  Offset getNextWindowPositionRatio(
    double windowWidth,
    double windowHeight,
    double parentWidth,
    double parentHeight,
  ) {
    log('call getNextWindowPositionRatio');

    if (windowPositionRatios.isEmpty) {
      log('windowPositionRatios.isEmpty');

      // Initial position as ratio
      final ratio = Offset(
        horizontalPadding / parentWidth,
        (parentHeight - windowHeight - verticalPadding) / parentHeight,
      );

      windowPositionRatios.add(ratio);
      return ratio;
    }

    log('windowPositionRatios length ${windowPositionRatios.length}');
    final lastWindowRatio = windowPositionRatios.last;

    // Convert ratio back to absolute position
    final lastWindowPosition = Offset(
      lastWindowRatio.dx * parentWidth,
      lastWindowRatio.dy * parentHeight,
    );

    // Calculate the new position
    double x = lastWindowPosition.dx + windowWidth + horizontalPadding;

    // Handle horizontal overflow
    if (x + windowWidth + horizontalBoundaryPadding > parentWidth) {
      x = horizontalPadding;
      double y = lastWindowPosition.dy - windowHeight - verticalPadding;

      // Handle vertical overflow
      if (y < 0) y = parentHeight - windowHeight - verticalPadding;

      // Convert new absolute position to ratio
      final newRatio = Offset(
        x / parentWidth,
        y / parentHeight,
      );

      windowPositionRatios.add(newRatio);
      return newRatio;
    }

    // Convert new absolute position to ratio
    final newRatio = Offset(
      x / parentWidth,
      (lastWindowPosition.dy) / parentHeight,
    );

    windowPositionRatios.add(newRatio);
    return newRatio;
  }

  void addWindowPosition(Offset position) {
    if (!windowPositionRatios.contains(position)) {
      windowPositionRatios.add(position);
    }
  }

  void removeWindowPosition(Offset position) {
    windowPositionRatios.remove(position);
  }
}
