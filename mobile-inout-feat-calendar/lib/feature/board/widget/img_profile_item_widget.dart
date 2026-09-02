import 'package:flutter/material.dart';
import 'package:mobile_in_out/core/utils/widgets/app_image_profile_rounded.dart';
import 'package:mobile_in_out/feature/board/model/profile_user_model.dart';

class ImgProfileItemWidget extends StatelessWidget {
  final List<ProfileUserModel>? profileUser;
  final int? maxVisible;

  const ImgProfileItemWidget({
    super.key,
    this.profileUser,
    this.maxVisible
  });
  
  @override
  Widget build(Object context) {
    final int maxVisibleProfile = maxVisible ?? 0;
    final int sizeProfileUser = profileUser?.length ?? 0;
    final double overLap = 0.6; // overlap 40%
    final double overLapPlus = 0.7; // tambahkan toleransi 0.1 dari overlap agar border tidak terpotong
    final double sizeImage = 30.0; 
    final double spaceImage = 5.0;
    final int displayCount = sizeProfileUser > maxVisibleProfile ? maxVisibleProfile : sizeProfileUser;

    if (sizeProfileUser == 0) {
      return SizedBox.shrink();
    } else {
      return SizedBox(
        height: sizeImage,
        width: sizeProfileUser > maxVisibleProfile ? ((displayCount + overLapPlus) * overLap) * sizeImage : displayCount * (sizeImage + spaceImage),
        child: Stack(
          children: [
            for (int i = 0; i < displayCount; i++)
              Positioned(
                left: sizeProfileUser > maxVisibleProfile ? i * (sizeImage * overLap) : i * (sizeImage + spaceImage), 
                child: AppImageProfileRounded(
                  profileUrl: profileUser?[i].imgUrl,
                  width: sizeImage,
                  height: sizeImage,
                  initialName: getInitials(profileUser?[i].userName),
                  initialNameSize: 13,
                  isBorder: true,
                ),
              ),
          ],
        ),
      );
    }
  }

  String getInitials(String? name) {
    if (name == null || name.isEmpty) return "";

    List<String> words = name.trim().split(" ");
    String initials = words.map((w) => w[0].toUpperCase()).join("");

    if (initials.length > 2) {
      return initials.substring(0, 2);
    }

    return initials;
  }

}