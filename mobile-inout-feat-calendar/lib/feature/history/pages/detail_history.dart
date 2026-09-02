import 'package:mobile_in_out/core/resources/theme/app_style.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/resources/theme/theme.dart';
import 'package:mobile_in_out/core/utils/enum_state.dart';
import 'package:mobile_in_out/core/utils/extensions/date_extension.dart';
import 'package:mobile_in_out/core/utils/extensions/widget_extension.dart';
import 'package:mobile_in_out/core/utils/localizations/app_translations.dart';
import 'package:mobile_in_out/core/utils/widgets/app_bar_general.dart';
import 'package:mobile_in_out/feature/history/provider/history_provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

@RoutePage()
class DetailHistory extends StatefulWidget {
  const DetailHistory({super.key, required this.absenceId});

  final String absenceId;

  @override
  State<DetailHistory> createState() => _DetailHistoryState();
}

class _DetailHistoryState extends State<DetailHistory> {
  late HistoryProvider historyProvider;

  @override
  void initState() {
    historyProvider = Provider.of<HistoryProvider>(context, listen: false);
    _getDetailHistory();
    super.initState();
  }

  _getDetailHistory() {
    Future.microtask(
      () => {historyProvider.getDetailHistory(widget.absenceId)},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarGeneral(
        backgroundColor: AppColors.whiteColor,
        colorIcon: AppColors.primaryColor,
        styleTitle: AppStyle(
          color: AppColors.blackColor,
          weight: bold,
        ).headline2,
        colorTitle: AppColors.blackColor,
        title: AppTranslations.translate('detail_history'),
        onBackPressed: () {
          context.router.popForced();
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Consumer<HistoryProvider>(
          builder: (context, provider, _) {
            final state = provider.stateDetail;
            final data = provider.detailHistory;

            if (state == RequestState.Loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state == RequestState.Error) {
              return Center(child: Text(provider.errorMessageDetail));
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    AppTranslations.translate('confirmed'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ).horizontalPadded(15),
                  const Divider(
                    color: Color(0xffF1F5F9),
                    thickness: 10,
                  ).verticalPadded(24),
                  Text(
                    AppTranslations.translate('location_in'),
                    style: AppTheme.bodyText.copyWith(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ).horizontalPadded(15),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xffF1F5F9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      data?.addressIn ??
                          AppTranslations.translate('unknown_location'),
                      style: AppTheme.subtitle,
                    ).horizontalPadded(15),
                  ).horizontalPadded(16).bottomPadded(),
                  const SizedBox(height: 10),
                  Text(
                    AppTranslations.translate('location_in_map'),
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ).horizontalPadded(15),
                  InkWell(
                    onTap: () {
                      // context.router.push(
                      // MapRoute(
                      //   currentPosition: provider.currentPosition!,
                      //   detailAddress: provider.currentAddress ?? "Unknown Location",
                      //   workLocation: locationProvider.workLocation,
                      // ),
                      // );
                    },
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.greyColor,
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          'https://maps.googleapis.com/maps/api/staticmap?center=${data?.latitudeIn},${data?.longitudeIn}&zoom=15&size=400x200&markers=color:red%7Clabel:C%7C${data?.latitudeIn},${data?.longitudeIn}&key=AIzaSyDs_YJEqyaAlKaFH-XaMyp8L6Hua7U05D0',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ).horizontalPadded(15).topPadded(16).bottomPadded(16),
                  const Divider(
                    color: Color(0xffF1F5F9),
                    thickness: 10,
                  ).verticalPadded(24),
                  Text(
                    AppTranslations.translate('location_out'),
                    style: AppTheme.bodyText.copyWith(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ).horizontalPadded(15),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xffF1F5F9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      data?.addressOut ??
                          AppTranslations.translate('unknown_location'),
                      style: AppTheme.subtitle,
                    ).horizontalPadded(15),
                  ).horizontalPadded(16).bottomPadded(),
                  const SizedBox(height: 10),
                  Text(
                    AppTranslations.translate('location_out_map'),
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ).horizontalPadded(15),
                  InkWell(
                    onTap: () {
                      // context.router.push(
                      // MapRoute(
                      //   currentPosition: provider.currentPosition!,
                      //   detailAddress: provider.currentAddress ?? "Unknown Location",
                      //   workLocation: locationProvider.workLocation,
                      // ),
                      // );
                    },
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.greyColor,
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          'https://maps.googleapis.com/maps/api/staticmap?center=${data?.latitudeOut},${data?.longitudeOut}&zoom=15&size=400x200&markers=color:red%7Clabel:C%7C${data?.latitudeOut},${data?.longitudeOut}&key=AIzaSyDs_YJEqyaAlKaFH-XaMyp8L6Hua7U05D0',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ).horizontalPadded(15).topPadded(16).bottomPadded(16),
                  const Divider(
                    color: Color(0xffF1F5F9),
                    thickness: 10,
                  ).verticalPadded(24),
                  Text(
                    AppTranslations.translate('time_in'),
                    style: AppTheme.bodyText.copyWith(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ).horizontalPadded(15),
                  const SizedBox(height: 10),
                  Text(
                    data?.dateIn?.formatDateTime() ??
                        AppTranslations.translate('unknown_time'),
                    style: AppTheme.subtitle,
                  ).horizontalPadded(15),
                  const Divider(
                    color: AppColors.greyColor,
                    thickness: 1,
                  ).horizontalPadded(15).verticalPadded(0),
                  Text(
                    AppTranslations.translate('time_out'),
                    style: AppTheme.bodyText.copyWith(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ).horizontalPadded(15),
                  const SizedBox(height: 10),
                  Text(
                    data?.dateOut?.formatDateTime() ??
                        AppTranslations.translate('unknown_time'),
                    style: AppTheme.subtitle,
                  ).horizontalPadded(15),
                  const Divider(
                    color: AppColors.greyColor,
                    thickness: 1,
                  ).horizontalPadded(15).verticalPadded(0),
                  Text(
                    AppTranslations.translate('date'),
                    style: AppTheme.bodyText.copyWith(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ).horizontalPadded(15),
                  const SizedBox(height: 10),
                  Text(
                    DateTime.now().toFormattedDate(),
                    style: AppTheme.subtitle.copyWith(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ).horizontalPadded(15),
                  const Divider(
                    color: Color(0xffF1F5F9),
                    thickness: 10,
                  ).verticalPadded(24),
                  Text(
                    AppTranslations.translate('note_in'),
                    style: AppTheme.bodyText.copyWith(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ).horizontalPadded(15),
                  const SizedBox(height: 10),
                  Text(
                    data?.noteIn ?? '-',
                    style: AppTheme.subtitle,
                  ).horizontalPadded(15),
                  const Divider(
                    color: AppColors.greyColor,
                    thickness: 1,
                  ).horizontalPadded(15).verticalPadded(0),
                  Text(
                    AppTranslations.translate('note_out'),
                    style: AppTheme.bodyText.copyWith(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ).horizontalPadded(15),
                  const SizedBox(height: 10),
                  Text(
                    data?.noteOut ?? '-',
                    style: AppTheme.subtitle,
                  ).horizontalPadded(15),
                  const Divider(
                    color: AppColors.greyColor,
                    thickness: 1,
                  ).horizontalPadded(15).verticalPadded(0),
                  Text(
                    AppTranslations.translate('photo_in'),
                    style: AppTheme.bodyText.copyWith(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ).horizontalPadded(15),
                  const SizedBox(height: 10),
                  Visibility(
                    visible: data?.photoInUrl != null && data?.photoInUrl != '',
                    child: Image.network(
                      data?.photoInUrl ?? '',
                      width: 100,
                      height: 100,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.broken_image,
                          size: 100,
                          color: Colors.grey,
                        );
                      },
                    ).horizontalPadded(15),
                  ),
                  const Divider(
                    color: AppColors.greyColor,
                    thickness: 1,
                  ).horizontalPadded(15).verticalPadded(0),
                  Text(
                    AppTranslations.translate('photo_out'),
                    style: AppTheme.bodyText.copyWith(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ).horizontalPadded(15),
                  const SizedBox(height: 10),
                  Visibility(
                    visible:
                        data?.photoOutUrl != null && data?.photoOutUrl != '',
                    child: Image.network(
                      data?.photoOutUrl ?? '',
                      width: 100,
                      height: 100,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.broken_image,
                          size: 100,
                          color: Colors.grey,
                        );
                      },
                    ).horizontalPadded(15),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
