// import 'package:mg_common_game/core/assets/asset_types.dart'; // Temporarily disabled - module doesn't exist yet

/// Spine 통합 플래그. `--dart-define=SPINE_ENABLED=true`로 활성화.
const kSpineEnabled = bool.fromEnvironment(
  'SPINE_ENABLED',
  defaultValue: false,
);

// ── Wanderer Knight ──────────────────────────────────────────

// const kWandererKnightMeta = SpineAssetMeta(
//   key: 'wanderer_knight',
//   path: 'spine/characters/wanderer_knight',
//   atlasPath:
//       'assets/spine/characters/wanderer_knight/wanderer_knight.atlas',
//   skeletonPath:
//       'assets/spine/characters/wanderer_knight/wanderer_knight.json',
//   animations: ['idle', 'walk', 'attack', 'hit'],
//   defaultAnimation: 'idle',
//   defaultMix: 0.2,
// );

// ── Wanderer Mage ────────────────────────────────────────────

// const kWandererMageMeta = SpineAssetMeta(
//   key: 'wanderer_mage',
//   path: 'spine/characters/wanderer_mage',
//   atlasPath:
//       'assets/spine/characters/wanderer_mage/wanderer_mage.atlas',
//   skeletonPath:
//       'assets/spine/characters/wanderer_mage/wanderer_mage.json',
//   animations: ['idle', 'walk', 'attack', 'hit'],
//   defaultAnimation: 'idle',
//   defaultMix: 0.2,
// );

// ── Wanderer Scout ───────────────────────────────────────────

// const kWandererScoutMeta = SpineAssetMeta(
//   key: 'wanderer_scout',
//   path: 'spine/characters/wanderer_scout',
//   atlasPath:
//       'assets/spine/characters/wanderer_scout/wanderer_scout.atlas',
//   skeletonPath:
//       'assets/spine/characters/wanderer_scout/wanderer_scout.json',
//   animations: ['idle', 'walk', 'attack', 'hit'],
//   defaultAnimation: 'idle',
//   defaultMix: 0.2,
// );
