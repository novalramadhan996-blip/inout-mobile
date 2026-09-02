import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/routes/router_import.gr.dart';
import 'package:mobile_in_out/core/utils/localizations/app_translations.dart';

class TodoItemWidget extends StatelessWidget {

  final String? todoId;
  final String? todoTitle;
  final String? todoDescription;
  final String? todoImageUrl;
  final int? todoTotalTask;
  final int? totalBoard;
  
  const TodoItemWidget({
    super.key,
    this.todoId,
    this.todoTitle,
    this.todoDescription,
    this.todoImageUrl,
    this.todoTotalTask,
    this.totalBoard,
  });

  @override
  Widget build(BuildContext context) {
    return  Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.router.push(
            BoardRoute(
              projectId: todoId ?? '',
              title: todoTitle ?? '',
              imgUrl: todoImageUrl ?? '',
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: todoImageUrl != null
                        ? Image.network(
                            todoImageUrl ?? '',
                            width: 94,
                            height: 71,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                              const SizedBox(
                                width: 94,
                                height: 71,
                                child: FittedBox(
                                  fit: BoxFit.fill,
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 94,
                                  ),
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
                          todoTitle ?? '',
                          style: const TextStyle(
                            fontSize: 14, 
                            fontWeight: FontWeight.w600,
                            color: AppColors.blackColor
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          todoDescription ?? '',
                          style: const TextStyle(
                            fontSize: 12, 
                            color: AppColors.greyFont,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (todoTotalTask != null)
                Container(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.check_box,
                          color: AppColors.greyComponent,
                          size: 17,
                        ),
                        SizedBox(width: 5),
                        Text(
                          '${totalBoard ?? 0} ${AppTranslations.translate('projects')}',
                          style: const TextStyle(
                            fontSize: 14, 
                            color: AppColors.greyComponent,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      ],
                    )
                  ),
                )
            ],
          ), 
        ),
      ),
    );
  }

}