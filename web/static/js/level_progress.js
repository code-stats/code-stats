/**
 * A level progress with an associated DOM element that is updated accordingly.
 *
 * DOM element must have, as child, exactly one element each of the following
 * classes:
 *   - xp-level
 *   - xp-amount
 *   - recent-xp-amount
 *
 * The text contents of these elements are updated when the level progress is
 * given more XP.
 *
 * DOM element must also have data attributes `xp` and `recent-xp` which will be
 * used to initialize the XP amounts.
 */

import { get_level } from './xp_calculator';
import { format_xp } from './utils';

class LevelProgress {
  constructor(elem) {
    this.elem = elem;
    this.initial_xp = parseInt(this.elem.dataset.xp);
    this.xp = parseInt(this.elem.dataset.xp);
    this.recent_xp = parseInt(this.elem.dataset.recentXp);

    this.level_elem = this.elem.getElementsByClassName('xp-level')[0];
    this.xp_elem = this.elem.getElementsByClassName('xp-amount')[0];
    this.recent_xp_elem = this.elem.getElementsByClassName('recent-xp-amount')[0];
  }

  add(xp) {
    this.xp += xp;
    this.recent_xp += xp;

    this.updateDOM();
  }

  updateDOM() {
    this.elem.dataset.xp = this.xp;
    this.elem.dataset.recentXp = this.recent_xp;

    this.level_elem.textContent = get_level(this.xp);
    this.xp_elem.textContent = format_xp(this.xp);
    this.recent_xp_elem.textContent = format_xp(this.recent_xp);
  }
}

export default LevelProgress;
