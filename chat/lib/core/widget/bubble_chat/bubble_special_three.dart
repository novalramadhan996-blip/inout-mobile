import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/core/resources/constants/app_constants.dart';
import 'package:flutter/material.dart';

// lib from https://pub.dev/packages/chat_bubbles
///iMessage's chat bubble type
///
///chat bubble color can be customized using [color]
///chat bubble tail can be customized  using [tail]
///chat bubble display message can be changed using [text]
///[text] is the only required parameter
///message sender can be changed using [isSender]
///chat bubble [TextStyle] can be customized using [textStyle]

class BubbleSpecialThree extends StatelessWidget {
  final bool isSender;
  final String text;
  final bool tail;
  final Color color;
  final bool sent;
  final bool delivered;
  final bool seen;
  final String time;
  final TextStyle textStyle;
  final BoxConstraints? constraints;
  final String type;
  final String name;
  final String image;
  final String typeMessage;
  final String? fileName;
  final String? fileType;
  final String? fileUrl;

  const BubbleSpecialThree({
    super.key,
    this.isSender = true,
    this.constraints,
    required this.text,
    this.color = Colors.white70,
    this.tail = true,
    this.sent = false,
    this.delivered = false,
    this.seen = false,
    this.time = "",
    required this.type,
    this.name = "",
    this.image = "",
    this.textStyle = const TextStyle(
      color: Colors.black87,
      fontSize: 16,
    ),
    required this.typeMessage,
    this.fileName,
    this.fileType,
    this.fileUrl,
  });

  EdgeInsets _getMarginValue(bool isSender, bool stateTick, bool isTime) {
    if (isSender) {
      if (isTime) {
        if (stateTick) {
          return const EdgeInsets.fromLTRB(7, 7, 14, 7);
        } else {
          return const EdgeInsets.fromLTRB(7, 7, 17, 7);
        }
      } else {
        if (stateTick) {
          return const EdgeInsets.fromLTRB(7, 7, 14, 7);
        } else {
          return const EdgeInsets.fromLTRB(7, 7, 17, 7);
        }
      }
    } else {
      return const EdgeInsets.fromLTRB(17, 7, 7, 7);
    }
  }

  EdgeInsets _getPaddingValue(bool stateTick, bool isTime) {
    if (isTime) {
      if (stateTick) {
        return const EdgeInsets.only(left: 4, right: 50);
      } else {
        return const EdgeInsets.only(left: 4, right: 30);
      }
    } else {
      if (stateTick) {
        return const EdgeInsets.only(left: 4, right: 20);
      } else {
        return const EdgeInsets.only(left: 4, right: 4);
      }
    }
  }

  Widget contentMessage(BuildContext context) {
    if (typeMessage == AppConstants.typeMessagetext) {
      return Text(
        text,
        style: textStyle,
        textAlign: TextAlign.left,
      );
    } else if (typeMessage == AppConstants.typeMessageImage) {
      log('image url: $fileUrl');
      return SizedBox(
        width: 200,
        height: 200,
        child: CachedNetworkImage(
          imageUrl: fileUrl ?? '',
          width: 200,
          height: 200,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) {
            log('error image: $error');
            return const Icon(Icons.error, size: 50, color: Colors.red);
          }
        )
      );
    } else {
      return Container(
        color: Colors.white,
        width: 180,
        height: 50,
        child: Padding(
          padding: const EdgeInsets.all(5),
            child: Row(
            children: [
              Icon(
                typeMessage == AppConstants.typeMessageVideo ? Icons.movie : Icons.insert_drive_file,
                color: Colors.grey.shade600,
                size: 30,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  fileName ?? '',
                  style: textStyle,
                  textAlign: TextAlign.left,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )
              ),
            ],
          )
        )
      );
    }
  }

  ///chat bubble builder method
  @override
  Widget build(BuildContext context) {
    bool stateTick = false;
    bool isTime = false;
    bool isGroup = false;
    Icon? stateIcon;
    Text? stateTime;
    Text? stateName;
    EdgeInsets marginValue;
    EdgeInsets paddingValue;
    if (sent) {
      stateTick = true;
      stateIcon = const Icon(
        Icons.done,
        size: 18,
        color: Color(0xFF97AD8E),
      );
    }
    if (delivered) {
      stateTick = true;
      stateIcon = const Icon(
        Icons.done_all,
        size: 18,
        color: Color(0xFF97AD8E),
      );
    }
    if (seen) {
      stateTick = true;
      stateIcon = const Icon(
        Icons.done_all,
        size: 18,
        color: Color.fromARGB(255, 68, 0, 255),
      );
    }
    if (time != "") {
      isTime = true;
      stateTime = Text(
        time,
        style : const TextStyle(
          color: Colors.grey,
          fontSize: 10,
        ),
      );
    }
    if (type == AppConstants.typeChatGroup && !isSender) {
      isGroup = true;
      stateName = Text(
        name,
        style : const TextStyle(
          color: Colors.blue,
          fontSize: 15,
        ),
        // textAlign: TextAlign.left
      );
    } 

    marginValue = _getMarginValue(isSender, stateTick, isTime);
    paddingValue = _getPaddingValue(stateTick, isTime);

    return Align(
      alignment: isSender ? Alignment.topRight : Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: CustomPaint(
          painter: SpecialChatBubbleOne(
              color: color,
              alignment: isSender ? Alignment.topRight : Alignment.topLeft,
              tail: tail),
          child: Container(
            constraints: constraints ??
                BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * .7,
                ),
            margin: marginValue,
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: paddingValue,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children : [
                      stateName != null && isGroup
                        ? stateName
                        : const SizedBox(
                            width: 1,
                          ),
                      contentMessage(context)
                    ]
                  )
                ),
                stateTime != null && isTime
                    ? Positioned(
                        bottom: 0,
                        right: 0,
                        child: Row(
                          children: [
                            stateTime,
                            stateIcon != null && stateTick
                              ? stateIcon 
                              : const SizedBox(
                                  width: 1,
                                ),
                          ],
                        ),
                      )
                    : stateIcon != null && stateTick
                        ? Positioned(
                            bottom: 0,
                            right: 0,
                            child : stateIcon 
                          )
                        : const SizedBox(
                            width: 1,
                          ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

///custom painter use to create the shape of the chat bubble
///
/// [color],[alignment] and [tail] can be changed

class SpecialChatBubbleOne extends CustomPainter {
  final Color color;
  final Alignment alignment;
  final bool tail;

  SpecialChatBubbleOne({
    required this.color,
    required this.alignment,
    required this.tail,
  });

  final double _radius = 10.0;
  final double _x = 10.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (alignment == Alignment.topRight) {
      if (tail) {
        canvas.drawRRect(
            RRect.fromLTRBAndCorners(
              0,
              0,
              size.width - _x,
              size.height,
              bottomLeft: Radius.circular(_radius),
              bottomRight: Radius.circular(_radius),
              topLeft: Radius.circular(_radius),
            ),
            Paint()
              ..color = this.color
              ..style = PaintingStyle.fill);
        var path = new Path();
        path.moveTo(size.width - _x, 0);
        path.lineTo(size.width - _x, 10);
        path.lineTo(size.width, 0);
        canvas.clipPath(path);
        canvas.drawRRect(
            RRect.fromLTRBAndCorners(
              size.width - _x,
              0.0,
              size.width,
              size.height,
              topRight: const Radius.circular(3),
            ),
            Paint()
              ..color = this.color
              ..style = PaintingStyle.fill);
      } else {
        canvas.drawRRect(
            RRect.fromLTRBAndCorners(
              0,
              0,
              size.width - _x,
              size.height,
              bottomLeft: Radius.circular(_radius),
              bottomRight: Radius.circular(_radius),
              topLeft: Radius.circular(_radius),
              topRight: Radius.circular(_radius),
            ),
            Paint()
              ..color = this.color
              ..style = PaintingStyle.fill);
      }
    } else {
      if (tail) {
        canvas.drawRRect(
            RRect.fromLTRBAndCorners(
              _x,
              0,
              size.width,
              size.height,
              bottomRight: Radius.circular(_radius),
              topRight: Radius.circular(_radius),
              bottomLeft: Radius.circular(_radius),
            ),
            Paint()
              ..color = this.color
              ..style = PaintingStyle.fill);
        var path = new Path();
        path.moveTo(_x, 0);
        path.lineTo(_x, 10);
        path.lineTo(0, 0);
        canvas.clipPath(path);
        canvas.drawRRect(
            RRect.fromLTRBAndCorners(
              0,
              0.0,
              _x,
              size.height,
              topLeft: Radius.circular(3),
            ),
            Paint()
              ..color = this.color
              ..style = PaintingStyle.fill);
      } else {
        canvas.drawRRect(
            RRect.fromLTRBAndCorners(
              _x,
              0,
              size.width,
              size.height,
              bottomRight: Radius.circular(_radius),
              topRight: Radius.circular(_radius),
              bottomLeft: Radius.circular(_radius),
              topLeft: Radius.circular(_radius),
            ),
            Paint()
              ..color = this.color
              ..style = PaintingStyle.fill);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}