import {el, mount} from 'redom';
import {clear_children} from '../../../common/js/utils';
import LevelCounterComponent from '../graphs/level_counter.component';
import ProgressBarComponent from '../graphs/progress_bar.component';

/**
 * Renders the profile information and total XP of the user.
 */
class TotalInfoComponent {
  constructor(init_el) {
    this.totalXp = 0;
    this.newXp = 0;

    this.username = document.getElementById('profile-username').dataset.name;
    this.registered_at = document.getElementById('registered-at').getAttribute('datetime');
    this.last_day_coded = document.getElementById('last-programmed-at').getAttribute('datetime');

    this.usernameEl = el('h1#profile-username', this.username);
    this.profileDetailList = el('ul#profile-detail-list', [
      el('li', [
        'User since ',
        el('time', this.registered_at, {datetime: this.registered_at}),
        '.'
      ]),
      el('li', [
        'Last programmed ',
        (this.last_day_coded != null) && el('time', this.last_day_coded, {datetime: this.last_day_coded}),
        (this.last_day_coded == null) && el('em', 'never'),
        '.'
      ])
    ]);

    this.levelCounter = new LevelCounterComponent('h2', null, 0, 0);
    this.progressBar = new ProgressBarComponent(0, 0);

    this.totalProgress = el('div#total-progress', [this.levelCounter, this.progressBar]);

    clear_children(init_el);
    mount(init_el, this.usernameEl);
    mount(init_el, this.profileDetailList);
    mount(init_el, this.totalProgress);
  }

  initData({total: {xp, new_xp}}) {
    this.totalXp = xp;
    this.newXp = new_xp;

    this._updateChildren();
  }

  update({xps}) {
    let new_xp = xps.reduce((acc, {amount}) => acc + amount, 0);

    this.totalXp += new_xp;
    this.newXp += new_xp;

    this._updateChildren();
  }

  _updateChildren() {
    this.levelCounter.update(this.totalXp, this.newXp);
    this.progressBar.update(this.totalXp, this.newXp);
  }
}

export default TotalInfoComponent;
