import 'dart:async';
import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/custom_alert_anim_type.dart';
import '../models/custom_alert_options.dart';
import '../models/custom_alert_type.dart';
import '../utils/custom_alert_animate.dart';
import 'custom_alert_container.dart';

/// Captures Enter (and optionally Space) for the default confirm action even when
/// no button is focused; requests focus after the first frame.
class _AlertKeyboardScope extends StatefulWidget {
  const _AlertKeyboardScope({
    required this.child,
    required this.onActivateConfirm,
    required this.confirmOnSpace,
  });

  final Widget child;
  final VoidCallback onActivateConfirm;
  final bool confirmOnSpace;

  @override
  State<_AlertKeyboardScope> createState() => _AlertKeyboardScopeState();
}

class _AlertKeyboardScopeState extends State<_AlertKeyboardScope> {
  late final FocusNode _node = FocusNode(debugLabel: 'CustomAlertDialog.keys');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _node.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _node,
      autofocus: true,
      skipTraversal: true,
      canRequestFocus: true,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        final key = event.logicalKey;
        final activate = key == LogicalKeyboardKey.enter ||
            (widget.confirmOnSpace && key == LogicalKeyboardKey.space);
        if (activate) {
          widget.onActivateConfirm();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: widget.child,
    );
  }
}

class CustomAlertDialog {
  static OverlayEntry? _currentEntry;
  static Timer? _timer;
  static bool _isShowing = false;

  static Future<void> show({
    BuildContext? context,
    required CustomAlertType type,
    String? title,
    String? text,
    TextAlign? titleAlignment,
    TextAlign? textAlignment,
    Widget? widget,
    CustomAlertAnimType animType = CustomAlertAnimType.scale,
    bool barrierDismissible = true,
    VoidCallback? onConfirmBtnTap,
    VoidCallback? onCancelBtnTap,
    String? confirmBtnText,
    String? cancelBtnText,
    Color confirmBtnColor = Colors.blue,
    Color cancelBtnColor = Colors.redAccent,
    TextStyle? confirmBtnTextStyle,
    TextStyle? cancelBtnTextStyle,
    Color backgroundColor = Colors.white,
    Color headerBackgroundColor = Colors.white,
    Color titleColor = Colors.black,
    Color textColor = Colors.black,
    Color? barrierColor,
    bool showCancelBtn = false,
    bool showConfirmBtn = true,
    double borderRadius = 15.0,
    String? customAsset,
    double? width,
    Duration? autoCloseDuration,
    bool disableBackBtn = false,
    /// When true, [LogicalKeyboardKey.space] acts like Enter (confirm).
    bool confirmOnSpace = false,
  }) async {
    hide();

    final OverlayState? overlay = _resolveOverlay(context);

    if (overlay == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final retryOverlay = _resolveOverlay(context);
        if (retryOverlay == null) {
          debugPrint('CustomAlertDialog: No Overlay found.');
          return;
        }

        show(
          context: context,
          type: type,
          title: title,
          text: text,
          titleAlignment: titleAlignment,
          textAlignment: textAlignment,
          widget: widget,
          animType: animType,
          barrierDismissible: barrierDismissible,
          onConfirmBtnTap: onConfirmBtnTap,
          onCancelBtnTap: onCancelBtnTap,
          confirmBtnText: confirmBtnText,
          cancelBtnText: cancelBtnText,
          confirmBtnColor: confirmBtnColor,
          cancelBtnColor: cancelBtnColor,
          confirmBtnTextStyle: confirmBtnTextStyle,
          cancelBtnTextStyle: cancelBtnTextStyle,
          backgroundColor: backgroundColor,
          headerBackgroundColor: headerBackgroundColor,
          titleColor: titleColor,
          textColor: textColor,
          barrierColor: barrierColor,
          showCancelBtn: showCancelBtn,
          showConfirmBtn: showConfirmBtn,
          borderRadius: borderRadius,
          customAsset: customAsset,
          width: width,
          autoCloseDuration: autoCloseDuration,
          disableBackBtn: disableBackBtn,
        );
      });
      return;
    }

    final options = CustomAlertOptions(
      timer: null,
      title: title,
      text: text,
      titleAlignment: titleAlignment,
      textAlignment: textAlignment,
      widget: widget,
      type: type,
      animType: animType,
      barrierDismissible: barrierDismissible,
      onConfirmBtnTap: () {
        hide();
        onConfirmBtnTap?.call();
      },
      onCancelBtnTap: () {
        hide();
        onCancelBtnTap?.call();
      },
      confirmBtnText: confirmBtnText ?? AppStrings.done,
      cancelBtnText: cancelBtnText ?? AppStrings.cancel,
      confirmBtnColor: confirmBtnColor,
      cancelBtnColor: cancelBtnColor,
      confirmBtnTextStyle: confirmBtnTextStyle,
      cancelBtnTextStyle: cancelBtnTextStyle,
      backgroundColor: backgroundColor,
      headerBackgroundColor: headerBackgroundColor,
      titleColor: titleColor,
      textColor: textColor,
      showCancelBtn: showCancelBtn,
      showConfirmBtn: showConfirmBtn,
      borderRadius: borderRadius,
      customAsset: customAsset,
      width: width,
    );

    Widget alert = AlertDialog(
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      content: CustomAlertContainer(options: options),
    );

    if (type != CustomAlertType.loading) {
      final focusNode = FocusNode();

      alert = RawKeyboardListener(
        focusNode: focusNode,
        autofocus: true,
        onKey: (event) {
          if (event is RawKeyUpEvent &&
              event.logicalKey == LogicalKeyboardKey.enter) {
            hide();
            onConfirmBtnTap?.call();
          }

          if (!disableBackBtn &&
              event is RawKeyUpEvent &&
              event.logicalKey == LogicalKeyboardKey.escape) {
            hide();
          }
        },
        child: alert,
      );
    }

    final entry = OverlayEntry(
      builder: (_) {
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    if (barrierDismissible) hide();
                  },
                  child: Container(
                    color: barrierColor ?? Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
              Positioned.fill(
                child: SafeArea(
                  child: Center(
                    child: PopScope(
                      canPop: !disableBackBtn,
                      onPopInvoked: (didPop) {
                        if (!didPop && !disableBackBtn) {
                          hide();
                        }
                      },
                      child: GestureDetector(
                        onTap: () {},
                        child: CustomAlertAnimate.getByType(
                          animType,
                          child: alert,
                          animation: const AlwaysStoppedAnimation(1.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    _currentEntry = entry;
    _isShowing = true;
    overlay.insert(entry);

    if (autoCloseDuration != null) {
      _timer?.cancel();
      _timer = Timer(autoCloseDuration, () {
        hide();
      });
      options.timer = _timer;
    }
  }

  static OverlayState? _resolveOverlay(BuildContext? context) {
    final navigatorOverlay = Get.key.currentState?.overlay;
    if (navigatorOverlay != null) return navigatorOverlay;

    final validContext = context ?? Get.overlayContext ?? Get.context;
    if (validContext == null) return null;

    return Overlay.maybeOf(validContext, rootOverlay: true);
  }

  static void hide() {
    _timer?.cancel();
    _timer = null;

    if (_currentEntry != null) {
      _currentEntry!.remove();
      _currentEntry = null;
    }

    _isShowing = false;
  }

  static void hideAll() {
    hide();
  }

  static bool get isShowing => _isShowing;
}