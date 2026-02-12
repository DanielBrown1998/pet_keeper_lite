import 'dart:math';
import 'package:flutter/material.dart';

/// A custom Text widget that ensures text doesn't break layout
/// when system font size is increased.
class TextPetKeeper extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool? softWrap;
  final TextDirection? textDirection;
  final Locale? locale;
  final StrutStyle? strutStyle;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;

  /// Maximum text scale factor allowed.
  /// Values above this will be clamped to prevent layout breaks.
  final double maxScaleFactor;

  const TextPetKeeper(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
    this.textDirection,
    this.locale,
    this.strutStyle,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.maxScaleFactor = 1.3,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final clampedTextScaler = _clampTextScaler(mediaQuery.textScaler);

    return MediaQuery(
      data: mediaQuery.copyWith(textScaler: clampedTextScaler),
      child: Text(
        data,
        style: style,
        textAlign: textAlign,
        overflow: overflow,
        maxLines: maxLines,
        softWrap: softWrap,
        textDirection: textDirection,
        locale: locale,
        strutStyle: strutStyle,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
        selectionColor: selectionColor,
      ),
    );
  }

  TextScaler _clampTextScaler(TextScaler scaler) {
    final scaleFactor = scaler.scale(1.0);
    final clampedFactor = min(scaleFactor, maxScaleFactor);
    return TextScaler.linear(clampedFactor);
  }
}

/// Extension to easily convert Text to TextPetKeeper
extension TextPetKeeperExtension on Text {
  TextPetKeeper toPetKeeper({double maxScaleFactor = 1.3}) {
    return TextPetKeeper(
      data ?? '',
      key: key,
      style: style,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      softWrap: softWrap,
      textDirection: textDirection,
      locale: locale,
      strutStyle: strutStyle,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
      maxScaleFactor: maxScaleFactor,
    );
  }
}
