import {el} from 'redom';

import ProgressCounterComponent from './progress-counter.component';
import {get_level, get_level_progress} from '../../common/js/xp_utils';

class LanguageProgressComponent {
  constructor() {
    this.nameEl = el('h4.language-name');
    this.progressCounter = new ProgressCounterComponent('h5');

    this.innerProgress = el('div.progress', { style: { width: '0%' } });
    this.progressBar = el('div.progress-bar', this.innerProgress);

    this.el = el('div.language-progress', this.nameEl, this.progressCounter, this.progressBar);

    this.name = '';
    this.xp = 0;
  }

  update({name, xp}) {
    this.name = name;
    this.xp = xp;

    this.nameEl.textContent = `${this.name} level ${get_level(this.xp)}`;
    this.innerProgress.style.width = `${get_level_progress(this.xp)}%`;
    this.progressCounter.update(this.xp);
  }
}

export default LanguageProgressComponent;
