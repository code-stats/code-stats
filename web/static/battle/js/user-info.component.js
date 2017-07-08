import {el} from 'redom';

import ProgressCounterComponent from './progress-counter.component';
import {get_level} from '../../common/js/xp_utils';

class UserInfoComponent {
  constructor() {
    this.nameEl = el('h2.user-name');
    this.progress = new ProgressCounterComponent('h3');

    this.el = el('div.user-info', this.nameEl, this.progress);

    this.username = '';
    this.totalXP = 0;
  }

  update(username, total_xp) {
    this.username = username;
    this.totalXP = total_xp;

    this.nameEl.textContent = `${this.username} level ${get_level(this.totalXP)}`;
    this.progress.update(this.totalXP);
  }
}

export default UserInfoComponent;
