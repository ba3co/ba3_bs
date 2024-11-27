// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// class DraggableFloatingWindow extends StatefulWidget {
//   final VoidCallback onClose;
//   final Widget child;
//
//   const DraggableFloatingWindow({super.key, required this.onClose, required this.child});
//
//   @override
//   State<DraggableFloatingWindow> createState() => _DraggableFloatingWindowState();
// }
//
// class _DraggableFloatingWindowState extends State<DraggableFloatingWindow> {
//   late double _x, _y, _width, _height;
//   final double _minWidth = 200.0, _minHeight = 200.0, edgeSize = 5.0;
//   bool _isResizing = false;
//   Offset? _resizeStartPosition;
//   SystemMouseCursor _currentCursor = SystemMouseCursors.basic;
//
//   final GlobalKey _floatingWindowKey = GlobalKey();
//   Size _parentSize = Size.zero; // Store the parent's current size
//
//   @override
//   void initState() {
//     super.initState();
//
//     _initializeWindow();
//   }
//
//   void _initializeWindow() {
//     _width = 1.sw * 0.7;
//     _height = 1.sh * 0.8;
//     _x = (1.sw - _width) / 2;
//     _y = (1.sh - _height) / 2;
//     _parentSize = Size(1.sw, 1.sh);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final newParentSize = Size(constraints.maxWidth, constraints.maxHeight);
//
//         // Rebuild window position and size if the parent size changes
//         if (_parentSize != newParentSize) {
//           _updateForParentSizeChange(newParentSize);
//         }
//
//         return GestureDetector(
//           onPanUpdate: (details) {
//             if (_isResizing) {
//               _resizeWindow(details, newParentSize.width, newParentSize.height);
//             } else {
//               _moveWindow(details, newParentSize.width, newParentSize.height);
//             }
//           },
//           onPanStart: (details) {
//             final Offset localPosition = _getLocalPosition(details.globalPosition);
//             if (_isOnEdge(localPosition)) {
//               _isResizing = true;
//               _resizeStartPosition = localPosition;
//             } else {
//               _isResizing = false;
//             }
//           },
//           onPanEnd: (_) {
//             _isResizing = false;
//             _resizeStartPosition = null;
//           },
//           child: Stack(
//             children: [
//               Positioned(
//                 left: _x,
//                 top: _y,
//                 child: MouseRegion(
//                   onHover: (event) {
//                     final Offset localPosition = _getLocalPosition(event.position);
//                     _updateCursor(localPosition);
//                   },
//                   cursor: _currentCursor,
//                   child: Material(
//                     key: _floatingWindowKey,
//                     elevation: 8,
//                     borderRadius: BorderRadius.circular(12),
//                     child: Container(
//                       width: _width,
//                       height: _height,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Column(
//                         children: [
//                           Align(
//                             alignment: Alignment.topRight,
//                             child: IconButton(
//                               icon: const Icon(Icons.close, color: Colors.red),
//                               onPressed: widget.onClose,
//                             ),
//                           ),
//                           widget.child
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   void _updateForParentSizeChange(Size newParentSize) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       setState(() {
//         _width = newParentSize.width * 0.7;
//         _height = newParentSize.height * 0.8;
//
//         _x = (newParentSize.width - _width) / 2;
//         _y = (newParentSize.height - _height) / 2;
//
//         _parentSize = newParentSize;
//       });
//     });
//   }
//
//   Offset _getLocalPosition(Offset globalPosition) {
//     final RenderBox renderBox = _floatingWindowKey.currentContext!.findRenderObject() as RenderBox;
//     return renderBox.globalToLocal(globalPosition);
//   }
//
//   void _moveWindow(DragUpdateDetails details, double screenWidth, double screenHeight) {
//     setState(() {
//       _x += details.delta.dx;
//       _y += details.delta.dy;
//       _x = _x.clamp(0, screenWidth - _width);
//       _y = _y.clamp(0, screenHeight - _height);
//     });
//   }
//
//   Timer? _debounceTimer;
//
//   void _resizeWindow(DragUpdateDetails details, double screenWidth, double screenHeight) {
//     // Immediate visual update
//     setState(() {
//       _applyResizeLogic(details, screenWidth, screenHeight);
//     });
//
//     // Debounced constraints enforcement
//     _debounceTimer?.cancel();
//     _debounceTimer = Timer(const Duration(milliseconds: 100), () {
//       setState(() {
//         _applyConstraints(screenWidth, screenHeight);
//       });
//     });
//   }
//
//   void _applyResizeLogic(DragUpdateDetails details, double screenWidth, double screenHeight) {
//     final dx = details.delta.dx;
//     final dy = details.delta.dy;
//
//     if (_resizeStartPosition == null) return;
//
//     if (_isOnLeftEdge(_resizeStartPosition!)) {
//       final newWidth = _width - dx;
//       if (newWidth >= _minWidth && newWidth <= screenWidth * .95) {
//         _width = newWidth;
//         _x += dx;
//       }
//     }
//     if (_isOnRightEdge(details.localPosition) && !_isOnLeftEdge(_resizeStartPosition!)) {
//       final newWidth = _width + dx;
//       if (newWidth >= _minWidth && newWidth <= screenWidth * .95) {
//         _width = newWidth;
//       }
//     }
//     if (_isOnTopEdge(_resizeStartPosition!)) {
//       final newHeight = _height - dy;
//       if (newHeight >= _minHeight && newHeight <= screenHeight * .95) {
//         _height = newHeight;
//         _y += dy;
//       }
//     }
//     if (_isOnBottomEdge(details.localPosition) && !_isOnTopEdge(_resizeStartPosition!)) {
//       final newHeight = _height + dy;
//       if (newHeight >= _minHeight && newHeight <= screenHeight * .95) {
//         _height = newHeight;
//       }
//     }
//   }
//
//   void _applyConstraints(double screenWidth, double screenHeight) {
//     _width = _width.clamp(_minWidth, screenWidth - _x);
//     _height = _height.clamp(_minHeight, screenHeight - _y);
//     _x = _x.clamp(0, screenWidth - _width);
//     _y = _y.clamp(0, screenHeight - _height);
//   }
//
//   void _updateCursor(Offset position) {
//     setState(() {
//       if (_isOnTopLeftCorner(position)) {
//         _currentCursor = SystemMouseCursors.resizeUpLeftDownRight;
//       } else if (_isOnTopRightCorner(position)) {
//         _currentCursor = SystemMouseCursors.resizeUpRightDownLeft;
//       } else if (_isOnBottomLeftCorner(position)) {
//         _currentCursor = SystemMouseCursors.resizeUpRightDownLeft;
//       } else if (_isOnBottomRightCorner(position)) {
//         _currentCursor = SystemMouseCursors.resizeUpLeftDownRight;
//       } else if (_isOnRightEdge(position)) {
//         _currentCursor = SystemMouseCursors.resizeLeftRight;
//       } else if (_isOnBottomEdge(position)) {
//         _currentCursor = SystemMouseCursors.resizeUpDown;
//       } else if (_isOnLeftEdge(position)) {
//         _currentCursor = SystemMouseCursors.resizeLeftRight;
//       } else if (_isOnTopEdge(position)) {
//         _currentCursor = SystemMouseCursors.resizeUpDown;
//       } else {
//         _currentCursor = SystemMouseCursors.move;
//       }
//     });
//   }
//
//   bool _isOnEdge(Offset position) =>
//       _isOnCorner(position) ||
//       _isOnRightEdge(position) ||
//       _isOnLeftEdge(position) ||
//       _isOnTopEdge(position) ||
//       _isOnBottomEdge(position);
//
//   bool _isOnRightEdge(Offset position) => position.dx >= _width - edgeSize;
//
//   bool _isOnLeftEdge(Offset position) => position.dx <= edgeSize;
//
//   bool _isOnTopEdge(Offset position) => position.dy <= edgeSize;
//
//   bool _isOnBottomEdge(Offset position) => position.dy >= _height - edgeSize;
//
//   bool _isOnCorner(Offset position) =>
//       (_isOnLeftEdge(position) || _isOnRightEdge(position)) && (_isOnTopEdge(position) || _isOnBottomEdge(position));
//
//   bool _isOnTopLeftCorner(Offset position) => _isOnLeftEdge(position) && _isOnTopEdge(position);
//
//   bool _isOnTopRightCorner(Offset position) => _isOnRightEdge(position) && _isOnTopEdge(position);
//
//   bool _isOnBottomLeftCorner(Offset position) => _isOnLeftEdge(position) && _isOnBottomEdge(position);
//
//   bool _isOnBottomRightCorner(Offset position) => _isOnRightEdge(position) && _isOnBottomEdge(position);
// }
