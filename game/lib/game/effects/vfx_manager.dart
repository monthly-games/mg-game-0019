import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

/// VFX Manager for Guild of Wanderers (MG-0019)
/// Guild + Cooperative + Idle RPG 게임 전용 이펙트 관리자
class VfxManager extends Component with HasGameRef {
  VfxManager();
  final Random _random = Random();

  // Guild Boss Battle Effects
  void showBossPhaseChange(Vector2 position) {
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 180), () {
        if (!isMounted) return;
        gameRef.add(_createExplosionEffect(position: position + Vector2((_random.nextDouble() - 0.5) * 80, (_random.nextDouble() - 0.5) * 60), color: i == 1 ? Colors.red : Colors.purple, count: 30, radius: 65));
      });
    }
    _triggerScreenShake(intensity: 10, duration: 0.7);
    gameRef.add(_PhaseText(position: position));
  }

  void showDamageNumber(Vector2 position, int damage, {bool isCritical = false, bool isCoopBonus = false}) {
    gameRef.add(_DamageNumber(position: position, damage: damage, isCritical: isCritical, isCoopBonus: isCoopBonus));
  }

  void showCoopCombo(Vector2 position, int comboCount) {
    gameRef.add(_createExplosionEffect(position: position, color: Colors.cyan, count: 25 + comboCount * 3, radius: 55 + comboCount * 5.0));
    gameRef.add(_createSparkleEffect(position: position, color: Colors.white, count: 15));
    gameRef.add(_ComboText(position: position, combo: comboCount));
  }

  void showSkillActivation(Vector2 position, Color skillColor) {
    gameRef.add(_createConvergeEffect(position: position, color: skillColor));
    gameRef.add(_createGroundCircle(position: position, color: skillColor));
  }

  // Guild Effects
  void showGuildRankUp(Vector2 position) {
    gameRef.add(_createExplosionEffect(position: position, color: Colors.amber, count: 45, radius: 85));
    for (int i = 0; i < 6; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (!isMounted) return;
        gameRef.add(_createSparkleEffect(position: position + Vector2((_random.nextDouble() - 0.5) * 100, (_random.nextDouble() - 0.5) * 70), color: Colors.yellow, count: 10));
      });
    }
    gameRef.add(_GuildRankText(position: position));
    _triggerScreenShake(intensity: 5, duration: 0.4);
  }

  void showMemberContribution(Vector2 position, int contribution) {
    gameRef.add(_createRisingEffect(position: position, color: Colors.lightBlue, count: 10, speed: 60));
    showNumberPopup(position, '+$contribution', color: Colors.cyan);
  }

  void showGuildSkillActivation(Vector2 position, Color skillColor) {
    gameRef.add(_createExplosionEffect(position: position, color: skillColor, count: 35, radius: 75));
    gameRef.add(_createSparkleEffect(position: position, color: Colors.white, count: 20));
    gameRef.add(_GuildSkillText(position: position));
  }

  // Progression Effects
  void showExpGain(Vector2 position, int amount) {
    gameRef.add(_createRisingEffect(position: position, color: Colors.lightBlue, count: 8, speed: 50));
    showNumberPopup(position, '+$amount EXP', color: Colors.lightBlue);
  }

  void showLevelUp(Vector2 position) {
    gameRef.add(_createExplosionEffect(position: position, color: Colors.amber, count: 40, radius: 70));
    gameRef.add(_createSparkleEffect(position: position, color: Colors.yellow, count: 18));
    gameRef.add(_LevelUpText(position: position));
  }

  void showGoldGain(Vector2 position, int amount) {
    gameRef.add(_createCoinEffect(position: position, count: (amount / 30).clamp(5, 15).toInt()));
    showNumberPopup(position, '+$amount G', color: Colors.amber);
  }

  void showNumberPopup(Vector2 position, String text, {Color color = Colors.white}) {
    gameRef.add(_NumberPopup(position: position, text: text, color: color));
  }

  void _triggerScreenShake({double intensity = 5, double duration = 0.3}) {
    if (gameRef.camera.viewfinder.children.isNotEmpty) {
      gameRef.camera.viewfinder.add(MoveByEffect(Vector2(intensity, 0), EffectController(duration: duration / 10, repeatCount: (duration * 10).toInt(), alternate: true)));
    }
  }

  // Private generators
  ParticleSystemComponent _createExplosionEffect({required Vector2 position, required Color color, required int count, required double radius}) {
    return ParticleSystemComponent(particle: Particle.generate(count: count, lifespan: 0.7, generator: (i) {
      final angle = _random.nextDouble() * 2 * pi; final speed = radius * (0.4 + _random.nextDouble() * 0.6);
      return AcceleratedParticle(position: position.clone(), speed: Vector2(cos(angle), sin(angle)) * speed, acceleration: Vector2(0, 100), child: ComputedParticle(renderer: (canvas, particle) {
        final opacity = (1.0 - particle.progress).clamp(0.0, 1.0);
        canvas.drawCircle(Offset.zero, 5 * (1.0 - particle.progress * 0.3), Paint()..color = color.withOpacity(opacity));
      }));
    }));
  }

  ParticleSystemComponent _createConvergeEffect({required Vector2 position, required Color color}) {
    return ParticleSystemComponent(particle: Particle.generate(count: 14, lifespan: 0.5, generator: (i) {
      final startAngle = (i / 14) * 2 * pi; final startPos = Vector2(cos(startAngle), sin(startAngle)) * 55;
      return MovingParticle(from: position + startPos, to: position.clone(), child: ComputedParticle(renderer: (canvas, particle) {
        canvas.drawCircle(Offset.zero, 4, Paint()..color = color.withOpacity((1.0 - particle.progress * 0.5).clamp(0.0, 1.0)));
      }));
    }));
  }

  ParticleSystemComponent _createSparkleEffect({required Vector2 position, required Color color, required int count}) {
    return ParticleSystemComponent(particle: Particle.generate(count: count, lifespan: 0.55, generator: (i) {
      final angle = _random.nextDouble() * 2 * pi; final speed = 50 + _random.nextDouble() * 45;
      return AcceleratedParticle(position: position.clone(), speed: Vector2(cos(angle), sin(angle)) * speed, acceleration: Vector2(0, 45), child: ComputedParticle(renderer: (canvas, particle) {
        final opacity = (1.0 - particle.progress).clamp(0.0, 1.0); final size = 3 * (1.0 - particle.progress * 0.5);
        final path = Path(); for (int j = 0; j < 4; j++) { final a = (j * pi / 2); if (j == 0) path.moveTo(cos(a) * size, sin(a) * size); else path.lineTo(cos(a) * size, sin(a) * size); } path.close();
        canvas.drawPath(path, Paint()..color = color.withOpacity(opacity));
      }));
    }));
  }

  ParticleSystemComponent _createRisingEffect({required Vector2 position, required Color color, required int count, required double speed}) {
    return ParticleSystemComponent(particle: Particle.generate(count: count, lifespan: 0.9, generator: (i) {
      final spreadX = (_random.nextDouble() - 0.5) * 35;
      return AcceleratedParticle(position: position.clone() + Vector2(spreadX, 0), speed: Vector2(0, -speed), acceleration: Vector2(0, -20), child: ComputedParticle(renderer: (canvas, particle) {
        final opacity = (1.0 - particle.progress).clamp(0.0, 1.0);
        canvas.drawCircle(Offset.zero, 3, Paint()..color = color.withOpacity(opacity));
      }));
    }));
  }

  ParticleSystemComponent _createGroundCircle({required Vector2 position, required Color color}) {
    return ParticleSystemComponent(particle: Particle.generate(count: 1, lifespan: 0.6, generator: (i) {
      return ComputedParticle(renderer: (canvas, particle) {
        final progress = particle.progress; final opacity = (1.0 - progress).clamp(0.0, 1.0);
        canvas.drawCircle(Offset(position.x, position.y), 18 + progress * 40, Paint()..color = color.withOpacity(opacity * 0.4)..style = PaintingStyle.stroke..strokeWidth = 3);
      });
    }));
  }

  ParticleSystemComponent _createCoinEffect({required Vector2 position, required int count}) {
    return ParticleSystemComponent(particle: Particle.generate(count: count, lifespan: 0.7, generator: (i) {
      final angle = -pi / 2 + (_random.nextDouble() - 0.5) * pi / 4; final speed = 130 + _random.nextDouble() * 80;
      return AcceleratedParticle(position: position.clone(), speed: Vector2(cos(angle), sin(angle)) * speed, acceleration: Vector2(0, 350), child: ComputedParticle(renderer: (canvas, particle) {
        final opacity = (1.0 - particle.progress * 0.2).clamp(0.0, 1.0);
        canvas.save(); canvas.rotate(particle.progress * 3 * pi);
        canvas.drawOval(const Rect.fromLTWH(-3, -2, 6, 4), Paint()..color = Colors.amber.withOpacity(opacity));
        canvas.restore();
      }));
    }));
  }
}

class _DamageNumber extends TextComponent {
  _DamageNumber({required Vector2 position, required int damage, required bool isCritical, required bool isCoopBonus}) : super(text: isCoopBonus ? '$damage!' : '$damage', position: position, anchor: Anchor.center, textRenderer: TextPaint(style: TextStyle(fontSize: isCritical ? 28 : (isCoopBonus ? 24 : 18), fontWeight: FontWeight.bold, color: isCoopBonus ? Colors.cyan : (isCritical ? Colors.yellow : Colors.white), shadows: [Shadow(color: isCoopBonus ? Colors.blue : Colors.black, blurRadius: 4, offset: const Offset(1, 1))])));
  @override Future<void> onLoad() async { await super.onLoad(); add(MoveByEffect(Vector2(0, -50), EffectController(duration: 0.8, curve: Curves.easeOut))); add(OpacityEffect.fadeOut(EffectController(duration: 0.8, startDelay: 0.3))); add(RemoveEffect(delay: 1.1)); }
}

class _ComboText extends TextComponent {
  _ComboText({required Vector2 position, required int combo}) : super(text: 'x$combo COMBO!', position: position + Vector2(0, -45), anchor: Anchor.center, textRenderer: TextPaint(style: TextStyle(fontSize: 22 + combo.clamp(0, 10).toDouble(), fontWeight: FontWeight.bold, color: combo >= 10 ? Colors.red : (combo >= 5 ? Colors.orange : Colors.cyan), shadows: const [Shadow(color: Colors.blue, blurRadius: 10)])));
  @override Future<void> onLoad() async { await super.onLoad(); scale = Vector2.all(0.5); add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.25, curve: Curves.elasticOut))); add(MoveByEffect(Vector2(0, -25), EffectController(duration: 1.0, curve: Curves.easeOut))); add(OpacityEffect.fadeOut(EffectController(duration: 1.0, startDelay: 0.4))); add(RemoveEffect(delay: 1.4)); }
}

class _PhaseText extends TextComponent {
  _PhaseText({required Vector2 position}) : super(text: 'PHASE CHANGE!', position: position, anchor: Anchor.center, textRenderer: TextPaint(style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.red, letterSpacing: 2, shadows: [Shadow(color: Colors.purple, blurRadius: 12)])));
  @override Future<void> onLoad() async { await super.onLoad(); scale = Vector2.all(0.3); add(ScaleEffect.to(Vector2.all(1.1), EffectController(duration: 0.4, curve: Curves.elasticOut))); add(OpacityEffect.fadeOut(EffectController(duration: 1.5, startDelay: 1.0))); add(RemoveEffect(delay: 2.5)); }
}

class _GuildRankText extends TextComponent {
  _GuildRankText({required Vector2 position}) : super(text: 'GUILD RANK UP!', position: position, anchor: Anchor.center, textRenderer: TextPaint(style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 2, shadows: [Shadow(color: Colors.orange, blurRadius: 15)])));
  @override Future<void> onLoad() async { await super.onLoad(); scale = Vector2.all(0.3); add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.5, curve: Curves.elasticOut))); add(RemoveEffect(delay: 3.0)); }
}

class _GuildSkillText extends TextComponent {
  _GuildSkillText({required Vector2 position}) : super(text: 'GUILD SKILL!', position: position + Vector2(0, -50), anchor: Anchor.center, textRenderer: TextPaint(style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.purple, shadows: [Shadow(color: Colors.purple, blurRadius: 12)])));
  @override Future<void> onLoad() async { await super.onLoad(); scale = Vector2.all(0.5); add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.3, curve: Curves.elasticOut))); add(MoveByEffect(Vector2(0, -20), EffectController(duration: 1.2, curve: Curves.easeOut))); add(OpacityEffect.fadeOut(EffectController(duration: 1.2, startDelay: 0.5))); add(RemoveEffect(delay: 1.7)); }
}

class _LevelUpText extends TextComponent {
  _LevelUpText({required Vector2 position}) : super(text: 'LEVEL UP!', position: position + Vector2(0, -40), anchor: Anchor.center, textRenderer: TextPaint(style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.amber, shadows: [Shadow(color: Colors.orange, blurRadius: 10)])));
  @override Future<void> onLoad() async { await super.onLoad(); scale = Vector2.all(0.5); add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.3, curve: Curves.elasticOut))); add(MoveByEffect(Vector2(0, -25), EffectController(duration: 1.2, curve: Curves.easeOut))); add(OpacityEffect.fadeOut(EffectController(duration: 1.2, startDelay: 0.5))); add(RemoveEffect(delay: 1.7)); }
}

class _NumberPopup extends TextComponent {
  _NumberPopup({required Vector2 position, required String text, required Color color}) : super(text: text, position: position, anchor: Anchor.center, textRenderer: TextPaint(style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color, shadows: const [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1))])));
  @override Future<void> onLoad() async { await super.onLoad(); add(MoveByEffect(Vector2(0, -25), EffectController(duration: 0.6, curve: Curves.easeOut))); add(OpacityEffect.fadeOut(EffectController(duration: 0.6, startDelay: 0.2))); add(RemoveEffect(delay: 0.8)); }
}
