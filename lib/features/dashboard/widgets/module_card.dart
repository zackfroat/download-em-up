import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../models/dashboard_module.dart';

/// Interactive navigation card for dashboard modules using the Original Enterprise minimalist design.
class ModuleCard extends StatefulWidget {
  final DashboardModule module;
  final VoidCallback onTap;

  const ModuleCard({
    super.key,
    required this.module,
    required this.onTap,
  });

  @override
  State<ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<ModuleCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final module = widget.module;
    final isComingSoon = module.isPlaceholder;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          transform: Matrix4.diagonal3Values(
            _isPressed ? 0.98 : (_isHovered ? 1.02 : 1.0),
            _isPressed ? 0.98 : (_isHovered ? 1.02 : 1.0),
            1.0,
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _isHovered
                  ? module.accentColor.withValues(alpha: 0.55)
                  : AppColors.borderLight,
              width: _isHovered ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? module.accentColor.withValues(alpha: 0.12)
                    : const Color(0x0A0F172A),
                blurRadius: _isHovered ? 14 : 8,
                offset: Offset(0, _isHovered ? 6 : 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Row: Icon container + Status Badge or Code
              LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 140;
                  final iconBoxSize = isCompact ? 38.0 : 44.0;
                  final iconSize = isCompact ? 20.0 : 22.0;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: iconBoxSize,
                        height: iconBoxSize,
                        decoration: BoxDecoration(
                          color: module.lightBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: module.accentColor.withValues(alpha: 0.20),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          module.icon,
                          color: module.accentColor,
                          size: iconSize,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: module.badgeText != null
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: const Color(0xFFCBD5E1), width: 0.8),
                                ),
                                child: Text(
                                  module.badgeText!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: AppColors.offWhite,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  module.shortCode,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: module.accentColor,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  );
                },
              ),

              // Title
              Text(
                module.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                  color: AppColors.darkText,
                ),
              ),

              // Bottom Cue
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isComingSoon ? 'In Pipeline' : 'Open Module',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isComingSoon
                          ? AppColors.textSubtle
                          : module.accentColor,
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: _isHovered
                          ? module.accentColor.withValues(alpha: 0.12)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: isComingSoon
                          ? AppColors.textSubtle
                          : (_isHovered
                              ? module.accentColor
                              : AppColors.textMuted),
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
