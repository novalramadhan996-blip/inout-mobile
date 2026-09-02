import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';

class ReplySpecialTextSpanBuilder extends SpecialTextSpanBuilder {
  @override
  SpecialText? createSpecialText(
    String flag, {
    TextStyle? textStyle,
    SpecialTextGestureTapCallback? onTap,
    required int index,
  }) {
    if (flag.startsWith('||')) {
      return ReplyPrefixText(textStyle);
    }
    return null;
  }
}

class ReplyPrefixText extends SpecialText {
  ReplyPrefixText(TextStyle? textStyle)
      : super('||', '||', textStyle);

  @override
  InlineSpan finishText() {
    final mention = getContent();
    final user = mention.replaceAll('||', '');

    return TextSpan(
      text: user,
      style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
      children: [
        const TextSpan(text: ' '),
      ],
    );
  }
}