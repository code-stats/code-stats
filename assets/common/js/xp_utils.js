/**
 * XP calculation related utilities
 */

const LEVEL_FACTOR = 0.025;

function get_level(xp) {
  return Math.floor(Math.sqrt(xp) * LEVEL_FACTOR);
}

function get_next_level_xp(level) {
  return Math.ceil((level + 1) / LEVEL_FACTOR) ** 2;
}

function get_level_progress(xp) {
  const level = get_level(xp);
  const current_level_xp = get_next_level_xp(level - 1);
  const next_level_xp = get_next_level_xp(level);
  const have_xp = xp - current_level_xp;
  const needed_xp = next_level_xp - current_level_xp;

  return Math.round((have_xp / needed_xp) * 100);
}

export {
  get_level,
  get_next_level_xp,
  get_level_progress
};
