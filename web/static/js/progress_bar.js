/**
 * A single progress bar with a name, XP and recent XP. Attached to a Bootstrap
 * progress bar DOM element, which it manages.
 */

import LevelProgress from './level_progress';
import { get_level, get_next_level_xp, get_level_progress } from './xp_calculator';

class ProgressBar extends LevelProgress {
  constructor(elem) {
    super(elem);

    this.progress_elem = elem.getElementsByClassName('progress')[0];

    // Get progress bar child elements
    this.base_bar = this.progress_elem.getElementsByClassName('progress-bar-success')[0];
    this.recent_bar = this.progress_elem.getElementsByClassName('progress-bar-warning')[0];
  }

  updateDOM() {
    super.updateDOM();

    const [base_width, recent_width] = this.getBarWidths();

    this.base_bar.style.width = `${base_width}%`;
    this.recent_bar.style.width = `${recent_width}%`;
  }

  getBarWidths() {
    const level = get_level(this.xp);
    const current_level_xp = get_next_level_xp(level - 1);

    const have_xp = this.xp - current_level_xp;

    if (have_xp > this.recent_xp) {
      return [
        get_level_progress(this.xp - this.recent_xp),
        get_level_progress(this.xp) - get_level_progress(this.xp - this.recent_xp)
      ];
    }
    else {
      return [
        0,
        get_level_progress(this.xp)
      ];
    }
  }
}

export default ProgressBar;
