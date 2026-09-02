import 'package:mobile_in_out/core/resources/constants/assets.dart';
import 'package:mobile_in_out/core/resources/theme/colors.dart';
import 'package:mobile_in_out/core/routes/router_import.gr.dart';
import 'package:chat/core/routes/router_import.gr.dart' as autoroute;
import 'package:mobile_in_out/core/utils/extensions/context_extension.dart';
import 'package:mobile_in_out/core/utils/helper/auth_helper.dart';
import 'package:mobile_in_out/core/utils/localizations/app_translations.dart';
import 'package:mobile_in_out/core/utils/widgets/app_list_tile.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Future<void> _logout() async {
    await AuthHelper.logout();
  }

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: [
        HomeRouteV2(),
        CalendarRoute(),
        autoroute.ChatRoute(),
        TodoRoute(),
      ],
      transitionBuilder: (context, child, animation) =>
          FadeTransition(opacity: animation, child: child),
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: AppColors.backgroundNavbar,
            currentIndex: tabsRouter.activeIndex,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              if (index == 4) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (context) {
                    return Container(
                      padding: const EdgeInsets.all(10),
                      color: AppColors.whiteColor,
                      width: double.infinity,
                      height: context.screenHeight,
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              onPressed: () => context.router.popForced(),
                              icon: const Icon(
                                Icons.close_rounded,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                          AppListTileWithDivider(
                            title: AppTranslations.translate('profile'),
                            leading: const Icon(
                              Icons.person_2_outlined,
                              color: AppColors.primaryColor,
                            ),
                            paddingTop: 3,
                            onTap: () {
                              context.router.pop();
                              context.router.push(const ProfileRoute());
                            },
                          ),
                          AppListTileWithDivider(
                            title: AppTranslations.translate('change_password'),
                            leading: const Icon(
                              Icons.password,
                              color: AppColors.primaryColor,
                            ),
                            paddingTop: 5,
                            onTap: () {
                              context.router.pop();
                              context.router.push(const ChangePasswordRoute());
                            },
                          ),

                          // Work arround for testing Register Face ID, please confirm where this menu should be placed
                          // AppListTileWithDivider(
                          //   title: 'Register Face ID',
                          //   leading: const Icon(
                          //     Icons.face,
                          //     color: AppColors.primaryColor,
                          //   ),
                          //   paddingTop: 5,
                          //   onTap: () {
                          //     context.router.pop();
                          //     context.router.push(RegisterFaceRoute());
                          //   },
                          // ),
                          AppListTileWithDivider(
                            title: AppTranslations.translate('report_activity'),
                            leading: const Icon(
                              Icons.camera_alt,
                              color: AppColors.primaryColor,
                            ),
                            paddingTop: 5,
                            onTap: () {
                              context.router.pop();
                              context.router.push(
                                const ListReportActivityRoute(),
                              );
                            },
                          ),

                          AppListTileWithDivider(
                            title: AppTranslations.translate('setting'),
                            leading: const Icon(
                              Icons.settings,
                              color: AppColors.primaryColor,
                            ),
                            paddingTop: 5,
                            onTap: () {
                              context.router.pop();
                              context.router.push(const SettingRoute());
                            },
                          ),

                          AppListTileWithDivider(
                            title: AppTranslations.translate('logout'),
                            leading: const Icon(
                              Icons.logout,
                              color: Color.fromARGB(255, 50, 86, 101),
                            ),
                            paddingTop: 5,
                            onTap: () => {_logout()},
                          ),
                        ],
                      ),
                    );
                  },
                );
                return;
              }
              tabsRouter.setActiveIndex(index);
            },
            items: _bottomItems,
          ),
        );
      },
    );
  }

  List<BottomNavigationBarItem> get _bottomItems {
    return [
      BottomNavigationBarItem(
        label: '',
        icon: Image.asset(
          Assets.icHomeNav,
          width: 30,
          height: 30,
          color: AppColors.greyInactiveIcon,
        ),
        activeIcon: Image.asset(
          Assets.icHomeNav,
          width: 30,
          height: 30,
          color: AppColors.blueActiveIcon,
        ),
      ),
      BottomNavigationBarItem(
        label: '',
        icon: Image.asset(
          Assets.icCalendarNav,
          width: 30,
          height: 30,
          color: AppColors.greyInactiveIcon,
        ),
        activeIcon: Image.asset(
          Assets.icCalendarNav,
          width: 30,
          height: 30,
          color: AppColors.blueActiveIcon,
        ),
      ),
      BottomNavigationBarItem(
        label: '',
        icon: Image.asset(
          Assets.icChatNav,
          width: 30,
          height: 30,
          color: AppColors.greyInactiveIcon,
        ),
        activeIcon: Image.asset(
          Assets.icChatNav,
          width: 30,
          height: 30,
          color: AppColors.blueActiveIcon,
        ),
      ),
      BottomNavigationBarItem(
        label: '',
        icon: Image.asset(
          Assets.icTodoNav,
          width: 30,
          height: 30,
          color: AppColors.greyInactiveIcon,
        ),
        activeIcon: Image.asset(
          Assets.icTodoNav,
          width: 30,
          height: 30,
          color: AppColors.blueActiveIcon,
        ),
      ),
      BottomNavigationBarItem(
        label: '',
        icon: Image.asset(
          Assets.icSettingNav,
          width: 30,
          height: 30,
          color: AppColors.greyInactiveIcon,
        ),
        activeIcon: Image.asset(
          Assets.icSettingNav,
          width: 30,
          height: 30,
          color: AppColors.blueActiveIcon,
        ),
      ),
    ];
  }
}
