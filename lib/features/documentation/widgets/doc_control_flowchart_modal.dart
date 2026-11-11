import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../models/controlled_drawing.dart';

/// Modal dialog illustrating the Centralized Document Control flowchart
/// exactly as rendered in the official architectural SOP.
class DocControlFlowchartModal extends StatelessWidget {
  final DocControlStage? activeStage;

  const DocControlFlowchartModal({
    super.key,
    this.activeStage,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 20,
        vertical: isMobile ? 12 : 24,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 780, maxHeight: 860),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.indigoAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.account_tree_rounded,
                      color: AppColors.indigoAccent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Centralized Document Control Workflow',
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkText,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Official SOP: Drawing Intake, Superseding, Offline Distribution, and AFC Sign-off',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.borderLight),

            // Scrollable Flowchart canvas
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildStartPill('START'),
                        _buildArrowDown(),
                        _buildProcessBox(
                          title: 'Admin / Document Controller Receives Approved Drawing',
                          subtitle: 'Incoming transmittal from lead consultant or client engineering',
                          isActive:
                              activeStage == DocControlStage.adminReceived,
                        ),
                        _buildArrowDown(),
                        _buildProcessBox(
                          title: 'File and Upload Approved Drawing into Document Management System',
                          subtitle: 'Archived into centralized DMS with indexing metadata',
                          isActive:
                              activeStage == DocControlStage.uploadedToDms,
                        ),
                        _buildArrowDown(),
                        _buildProcessBox(
                          title: 'Verify Drawing Number, Revision and Approval Status',
                          subtitle: 'Cross-check against drawing register and AFC stamp validity',
                          isActive:
                              activeStage == DocControlStage.verifyingStatus,
                        ),
                        _buildArrowDown(),

                        // Decision Card: Is Drawing Resubmission Required?
                        _buildDecisionCard(
                          question: 'Is Drawing Resubmission Required?',
                          yesLabel: 'Remove Previous & Upload Latest Revision',
                          noLabel: 'Maintain Current Approved Drawing in System',
                          isYesActive: activeStage ==
                              DocControlStage.resubmissionRequired,
                          isNoActive: activeStage ==
                                  DocControlStage.maintainedCurrent ||
                              activeStage == DocControlStage.siteNotified ||
                              activeStage ==
                                  DocControlStage.downloadedOffline ||
                              activeStage ==
                                  DocControlStage.activeConstruction,
                        ),

                        _buildArrowDown(),
                        _buildProcessBox(
                          title: 'Notify Site Team of Approved Drawing Availability',
                          subtitle: 'Automated push alert & notification to site engineers and foremen',
                          isActive:
                              activeStage == DocControlStage.siteNotified,
                        ),
                        _buildArrowDown(),
                        _buildProcessBox(
                          title: 'Site Team Downloads Latest Approved Drawing from System',
                          subtitle: 'Field team retrieves AFC vector PDF / DWG on mobile and tablets',
                          isActive:
                              activeStage == DocControlStage.downloadedOffline,
                        ),
                        _buildArrowDown(),
                        _buildProcessBox(
                          title: 'Ensure Drawing is Accessible Offline at Site',
                          subtitle: 'Encrypted local cache for remote construction zones without Wi-Fi',
                          isActive:
                              activeStage == DocControlStage.downloadedOffline,
                        ),
                        _buildArrowDown(),
                        _buildProcessBox(
                          title: 'Site Team Uses Latest Approved Drawing for Construction',
                          subtitle: 'Zero superseded drawings on site; strictly building per latest revision',
                          isActive:
                              activeStage == DocControlStage.activeConstruction,
                        ),
                        _buildArrowDown(),
                        _buildStartPill('FINISH', isEnd: true),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartPill(String label, {bool isEnd = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 7),
      decoration: BoxDecoration(
        color: isEnd ? const Color(0xFF10B981) : const Color(0xFF4F46E5),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildArrowDown() {
    return Column(
      children: [
        Container(
          width: 2,
          height: 16,
          color: AppColors.borderLight,
        ),
        const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.textSubtle),
      ],
    );
  }

  Widget _buildProcessBox({
    required String title,
    required String subtitle,
    bool isActive = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.indigoAccent.withValues(alpha: 0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? AppColors.indigoAccent : AppColors.borderLight,
          width: isActive ? 2.0 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              color: isActive ? AppColors.indigoAccent : AppColors.darkText,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecisionCard({
    required String question,
    required String yesLabel,
    required String noLabel,
    required bool isYesActive,
    required bool isNoActive,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.help_outline_rounded,
                  color: Color(0xFFD97706), size: 18),
              const SizedBox(width: 6),
              Text(
                question,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF92400E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 460;

              final noWidget = Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isNoActive ? const Color(0xFFDCFCE7) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isNoActive ? const Color(0xFF16A34A) : AppColors.borderLight,
                    width: isNoActive ? 1.8 : 1.0,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'NO (Approved)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      noLabel,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                      ),
                    ),
                  ],
                ),
              );

              final yesWidget = Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isYesActive ? const Color(0xFFFEE2E2) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isYesActive ? const Color(0xFFDC2626) : AppColors.borderLight,
                    width: isYesActive ? 1.8 : 1.0,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'YES (Resubmission)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      yesLabel,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                      ),
                    ),
                  ],
                ),
              );

              if (isNarrow) {
                return Column(
                  children: [
                    noWidget,
                    const SizedBox(height: 8),
                    yesWidget,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: noWidget),
                  const SizedBox(width: 10),
                  Expanded(child: yesWidget),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

