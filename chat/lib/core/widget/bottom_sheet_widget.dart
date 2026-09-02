import 'package:chat/core/resources/constants/assets.dart';
import 'package:flutter/material.dart';

class BottomSheetWidget {

  static void showBottomSheetWidget(BuildContext context, Widget widgets) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.9,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Future.delayed(const Duration(milliseconds: 100));
                            FocusScope.of(context).unfocus();
                          },
                          child: Image.asset(
                            Assets.icClose,
                            height: 40,
                          ),
                        )
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: widgets
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (context.mounted) {
        FocusScope.of(context).unfocus();
      }
    });
  }

}