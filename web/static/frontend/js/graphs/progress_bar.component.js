import {el} from 'redom';
import {get_level, get_next_level_xp, get_level_progress} from '../../../common/js/xp_utils';


class ProgressBarComponent {
  constructor(total_xp, new_xp) {
    this.totalXp = total_xp;
    this.newXp = new_xp;

    this.oldProgressEl = el('span.progress.progress-old', {
      role: 'progressbar'
    });
    this.newProgressEl = el('span.progress.progress-recent', {
      role: 'progressbar'
    });
    this.progressText = el('span.total-progress', {
      'aria-hidden': 'true'
    });
    this.el = el('div.progress-bar', [this.oldProgressEl, this.newProgressEl, this.progressText]);

    this._refresh();
  }

  update(total_xp, new_xp) {
    this.totalXp = total_xp;
    this.newXp = new_xp;

    this._refresh();
  }

  // Refresh display based on given values
  _refresh() {
    const [old_progress, new_progress] = this._getXPBarWidths();
    const [old_text, new_text] = ProgressBarComponent._getValueTexts(old_progress, new_progress);

    this.oldProgressEl.setAttribute('aria-valuetext', old_text);
    this.newProgressEl.setAttribute('aria-valuetext', new_text);

    if (new_progress === 0) {
      this.newProgressEl.setAttribute('aria-hidden', 'true');
      this.el.classList.remove('stacked');
    }
    else {
      this.newProgressEl.setAttribute('aria-hidden', 'false');
      this.el.classList.add('stacked');
    }

    this.oldProgressEl.style.width = `${old_progress}%`;
    this.newProgressEl.style.width = `${new_progress}%`;

    this.progressText.textContent = `${old_progress + new_progress} %`;
  }

  // Get values as readable text for screen readers
  static _getValueTexts(old_progress, new_progress) {
    const total_progress = old_progress + new_progress;
    return [
      `Level progress ${total_progress} %.`,
      `Recent level progress ${new_progress} %.`
    ];
  }

  _getXPBarWidths() {
    const level = get_level(this.totalXp);
    const current_level_xp = get_next_level_xp(level - 1);

    const have_xp = this.totalXp - current_level_xp;

    if (have_xp > this.newXp) {
      return [
        get_level_progress(this.totalXp - this.newXp),
        get_level_progress(this.totalXp) - get_level_progress(this.totalXp - this.newXp)
      ];
    }
    else {
      return [0, get_level_progress(this.totalXp)];
    }
  }
}

export default ProgressBarComponent;
