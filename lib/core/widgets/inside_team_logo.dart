import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// InsideTeam logo widget using the new comic-style telecom tower image.
/// Falls back to a teal circle icon if the asset is unavailable.
class InsideTeamLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool isLightOnDark;
  final double? fontSize;

  const InsideTeamLogo({
    super.key,
    this.size = 64,
    this.showText = false,
    this.isLightOnDark = false,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final mark = SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.18),
        child: Image.asset(
          'assets/images/app_logo.jpg',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.teal,
              borderRadius: BorderRadius.circular(size * 0.18),
            ),
            child: Icon(
              Icons.cell_tower_rounded,
              color: Colors.white,
              size: size * 0.55,
            ),
          ),
        ),
      ),
    );

    if (!showText) {
      return mark;
    }

    final double titleSize = fontSize ?? (size * 0.35).clamp(16.0, 32.0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        mark,
        SizedBox(width: size * 0.22),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Inside',
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: isLightOnDark ? Colors.white : AppColors.darkText,
                  ),
                ),
                Text(
                  'Team',
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: AppColors.teal,
                  ),
                ),
              ],
            ),
            Text(
              'CONSTRUCTION MANAGEMENT',
              style: TextStyle(
                fontSize: (titleSize * 0.32).clamp(8.0, 12.0),
                fontWeight: FontWeight.w700,
                letterSpacing: 1.6,
                color: isLightOnDark ? AppColors.skyBlue : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
