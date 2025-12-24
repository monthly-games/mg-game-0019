import 'package:flutter/material.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';
import 'package:mg_common_game/core/ui/layout/mg_spacing.dart';
import 'package:mg_common_game/core/ui/typography/mg_text_styles.dart';
import 'package:mg_common_game/core/ui/widgets/buttons/mg_icon_button.dart';
import 'package:mg_common_game/core/ui/widgets/progress/mg_linear_progress.dart';
import 'package:mg_common_game/core/ui/widgets/indicators/mg_resource_bar.dart';

/// MG-0019 Idle Raid Clicker HUD
/// 방치형 레이드 게임용 HUD - 스테이지, 골드, DPS, 보스 HP 표시
class MGIdleRaidHud extends StatelessWidget {
  final int stage;
  final int gold;
  final int clickDamage;
  final double teamDps;
  final int bossHp;
  final int bossMaxHp;
  final String bossName;
  final bool isAutoBattle;
  final VoidCallback? onPause;
  final VoidCallback? onToggleAuto;

  const MGIdleRaidHud({
    super.key,
    required this.stage,
    required this.gold,
    required this.clickDamage,
    required this.teamDps,
    required this.bossHp,
    required this.bossMaxHp,
    required this.bossName,
    this.isAutoBattle = false,
    this.onPause,
    this.onToggleAuto,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(MGSpacing.sm),
        child: Column(
          children: [
            // 상단 HUD
            Row(
              children: [
                // 왼쪽: 스테이지 정보
                _buildStageInfo(),
                const Spacer(),
                // 오른쪽: 자원 & 버튼
                MGResourceBar(
                  resources: [
                    ResourceItem(
                      icon: Icons.monetization_on,
                      value: gold,
                      color: MGColors.resourceGold,
                    ),
                  ],
                ),
                SizedBox(width: MGSpacing.sm),
                if (onPause != null)
                  MGIconButton(
                    icon: Icons.pause,
                    onPressed: onPause!,
                    size: MGIconButtonSize.small,
                  ),
              ],
            ),
            SizedBox(height: MGSpacing.sm),
            // DPS 표시
            _buildDpsInfo(),
            const Spacer(),
            // 하단: 보스 HP
            _buildBossHpBar(),
            SizedBox(height: MGSpacing.sm),
            // 오토 배틀 버튼
            if (onToggleAuto != null) _buildAutoButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildStageInfo() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MGSpacing.md,
        vertical: MGSpacing.xs,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MGColors.primaryAction.withOpacity(0.8),
            MGColors.primaryAction.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(MGSpacing.sm),
        border: Border.all(color: MGColors.primaryAction),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag, color: Colors.white, size: 20),
          SizedBox(width: MGSpacing.xs),
          Text(
            'Stage $stage',
            style: MGTextStyles.buttonMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDpsInfo() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MGSpacing.sm,
        vertical: MGSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: MGColors.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(MGSpacing.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 클릭 데미지
          Icon(Icons.touch_app, color: Colors.orange, size: 16),
          SizedBox(width: MGSpacing.xxs),
          Text(
            '$clickDamage',
            style: MGTextStyles.caption.copyWith(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: MGSpacing.md),
          // 팀 DPS
          Icon(Icons.auto_awesome, color: Colors.cyan, size: 16),
          SizedBox(width: MGSpacing.xxs),
          Text(
            '${teamDps.toInt()} DPS',
            style: MGTextStyles.caption.copyWith(
              color: Colors.cyan,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBossHpBar() {
    final double hpRatio = bossMaxHp > 0 ? bossHp / bossMaxHp : 0;

    return Container(
      padding: EdgeInsets.all(MGSpacing.sm),
      decoration: BoxDecoration(
        color: MGColors.surface.withOpacity(0.85),
        borderRadius: BorderRadius.circular(MGSpacing.sm),
        border: Border.all(color: Colors.red.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 보스 이름
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.dangerous, color: Colors.red, size: 18),
              SizedBox(width: MGSpacing.xs),
              Text(
                bossName,
                style: MGTextStyles.buttonMedium.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: MGSpacing.xs),
          // HP 바
          MGLinearProgress(
            value: hpRatio,
            height: 16,
            backgroundColor: Colors.red.withOpacity(0.2),
            progressColor: Colors.red,
          ),
          SizedBox(height: MGSpacing.xxs),
          Text(
            '$bossHp / $bossMaxHp',
            style: MGTextStyles.caption.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoButton() {
    return GestureDetector(
      onTap: onToggleAuto,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: MGSpacing.lg,
          vertical: MGSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isAutoBattle
              ? Colors.green.withOpacity(0.8)
              : MGColors.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(MGSpacing.sm),
          border: Border.all(
            color: isAutoBattle ? Colors.greenAccent : MGColors.border,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isAutoBattle ? Icons.play_circle : Icons.play_circle_outline,
              color: isAutoBattle ? Colors.white : Colors.grey,
              size: 20,
            ),
            SizedBox(width: MGSpacing.xs),
            Text(
              isAutoBattle ? 'AUTO ON' : 'AUTO OFF',
              style: MGTextStyles.buttonMedium.copyWith(
                color: isAutoBattle ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
