import {list} from 'redom';

import LanguageProgressComponent from './language-progress.component';

const MAX_LANGS = 10;

class LanguageListComponent {
  constructor(log) {
    this.el = list('div', LanguageProgressComponent);

    this.languages = [];
  }

  update(languages) {
    this.languages = languages;
    this.languages.sort((a, b) => b.xp - a.xp);
    this.el.update(this.languages.slice(0, MAX_LANGS));
  }
}

export default LanguageListComponent;
