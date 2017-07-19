import {el} from 'redom';
import {get_level} from '../../../common/js/xp_utils';

class LevelCounterComponent {
  constructor(element_type, prefix, total_xp, new_xp) {
    this.totalXp = total_xp;
    this.newXp = new_xp;
    this.level = 0;
    this.prefixEl = null;
    this.contentEl = el('span.total-xp');
    this.postfixEl = el('span.recent-xp');

    if (prefix != null) {
      this.prefixEl = el('strong.level-prefix', prefix);
    }

    this.el = el(
      `${element_type}.level-counter`,
      [
        (this.prefixEl != null) && this.prefixEl,
        this.contentEl,
        this.postfixEl
      ]
    );

    this._refresh();
  }

  update(total_xp, new_xp) {
    this.totalXp = total_xp;
    this.newXp += new_xp;

    this._refresh();
  }

  _refresh() {
    this.level = get_level(this.totalXp);

    let title = ` level ${this.level} (${this.totalXp.toLocaleString()} XP)`;
    let postfix = '';

    if (this.prefixEl == null) {
      title = title.charAt(1).toUpperCase() + title.slice(2);
    }

    if (this.newXp > 0) {
      postfix = ` (+${this.newXp.toLocaleString()})`;
    }

    this.contentEl.textContent = title;
    this.postfixEl.textContent = postfix;
  }
}

export default LevelCounterComponent;
