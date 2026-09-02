import 'package:flutter/material.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/utils/helper/date_helper.dart';

class ItemReportActivity extends StatelessWidget {
  final String? id;
  final String? image;
  final String? title;
  final String? desc;
  final DateTime? date;

  const ItemReportActivity({
    super.key,
    this.id,
    this.image,
    this.title,
    this.desc,
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.access_time, size: 16, color: AppColors.greyFont),
                  SizedBox(width: 5),
                  Text(
                    (date != null)
                        ? DateHelper.convertStringToDateTimeFormat(
                                date!,
                                "MMMM dd, yyyy HH:mm",
                              ) ??
                              '-'
                        : '-',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.greyFont,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: image != null
                        ? Image.network(
                            image ?? '',
                            width: 94,
                            height: 71,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const SizedBox(
                                  width: 94,
                                  height: 71,
                                  child: FittedBox(
                                    fit: BoxFit.fill,
                                    child: Icon(Icons.broken_image, size: 94),
                                  ),
                                ),
                          )
                        : const SizedBox(
                            width: 94,
                            height: 71,
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: Icon(
                                Icons.broken_image,
                                color: AppColors.greyComponent,
                                size: 94,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blackColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          desc ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.greyFont,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
