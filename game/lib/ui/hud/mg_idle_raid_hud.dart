import 'package:mg_common_game/mg_common_game.dart';
import 'package:flutter/material.dart';

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
  final VoidCallback? onDailyHub;
  final VoidCallback? onGuildWar;
  final VoidCallback? onTournament;
  final VoidCallback? onSeasonalEvent;

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
    this.onDailyHub,
    this.onGuildWar,
    this.onTournament,
    this.onSeasonalEvent,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(MGSpacing.sm),
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
                  icon: Icons.monetization_on,
                  value: gold.toString(),
                  iconColor: MGColors.gold,
                ),
                const SizedBox(width: MGSpacing.sm),
                if (onGuildWar != null)
                  MGIconButton(
                    icon: Icons.shield,
                    onPressed: onGuildWar!,
                    buttonSize: MGIconButtonSize.small,
                  ),
                const SizedBox(width: MGSpacing.xs),
                if (onTournament != null)
                  MGIconButton(
                    icon: Icons.emoji_events,
                    onPressed: onTournament!,
                    buttonSize: MGIconButtonSize.small,
                  ),
                const SizedBox(width: MGSpacing.xs),
                if (onSeasonalEvent != null)
                  MGIconButton(
                    icon: Icons.celebration,
                    onPressed: onSeasonalEvent!,
                    buttonSize: MGIconButtonSize.small,
                  ),
                const SizedBox(width: MGSpacing.xs),
                if (onDailyHub != null)
                  MGIconButton(
                    icon: Icons.calendar_today,
                    onPressed: onDailyHub!,
                    buttonSize: MGIconButtonSize.small,
                  ),
                const SizedBox(width: MGSpacing.xs),
                if (onPause != null)
                  MGIconButton(
                    icon: Icons.pause,
                    onPressed: onPause!,
                    buttonSize: MGIconButtonSize.small,
                  ),
              ],
            ),
            const SizedBox(height: MGSpacing.sm),
            // DPS 표시
            _buildDpsInfo(),
            const Spacer(),
            // 하단: 보스 HP
            _buildBossHpBar(),
            const SizedBox(height: MGSpacing.sm),
            // 오토 배틀 버튼
            if (onToggleAuto != null) _buildAutoButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildStageInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MGSpacing.md,
        vertical: MGSpacing.xs,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MGColors.primaryAction.withValues(alpha: 0.8),
            MGColors.primaryAction.withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(MGSpacing.sm),
        border: Border.all(color: MGColors.primaryAction),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.flag, color: MGColors.textHighEmphasis, size: 20),
          const SizedBox(width: MGSpacing.xs),
          Text(
            'Stage $stage',
            style: MGTextStyles.buttonMedium.copyWith(
              color: MGColors.textHighEmphasis,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDpsInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MGSpacing.sm,
        vertical: MGSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: MGColors.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(MGSpacing.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 클릭 데미지
          const Icon(Icons.touch_app, color: MGColors.warning, size: 16),
          const SizedBox(width: MGSpacing.xxs),
          Text(
            '$clickDamage',
            style: MGTextStyles.caption.copyWith(
              color: MGColors.warning,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: MGSpacing.md),
          // 팀 DPS
          const Icon(Icons.auto_awesome, color: Colors.cyan, size: 16),
          const SizedBox(width: MGSpacing.xxs),
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
      padding: const EdgeInsets.all(MGSpacing.sm),
      decoration: BoxDecoration(
        color: MGColors.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(MGSpacing.sm),
        border: Border.all(color: MGColors.error.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 보스 이름
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.dangerous, color: MGColors.error, size: 18),
              const SizedBox(width: MGSpacing.xs),
              Text(
                bossName,
                style: MGTextStyles.buttonMedium.copyWith(
                  color: MGColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: MGSpacing.xs),
          // HP 바
          MGLinearProgress(
            value: hpRatio,
            height: 16,
            backgroundColor: MGColors.error.withValues(alpha: 0.2),
            valueColor: MGColors.error,
          ),
          const SizedBox(height: MGSpacing.xxs),
          Text(
            '$bossHp / $bossMaxHp',
            style: MGTextStyles.caption.copyWith(
              color: MGColors.textHighEmphasis,
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
        padding: const EdgeInsets.symmetric(
          horizontal: MGSpacing.lg,
          vertical: MGSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isAutoBattle
              ? MGColors.success.withValues(alpha: 0.8)
              : MGColors.surface.withValues(alpha: 0.8),
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
              color: isAutoBattle ? MGColors.textHighEmphasis : MGColors.common,
              size: 20,
            ),
            const SizedBox(width: MGSpacing.xs),
            Text(
              isAutoBattle ? 'AUTO ON' : 'AUTO OFF',
              style: MGTextStyles.buttonMedium.copyWith(
                color: isAutoBattle ? MGColors.textHighEmphasis : MGColors.common,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
