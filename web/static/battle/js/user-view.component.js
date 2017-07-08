import {el} from 'redom';

import UserInfoComponent from './user-info.component';
import LanguageListComponent from './language-list.component';

const TOTAL_COLUMNS = 12;

class UserViewComponent {
  constructor() {
    this.info = new UserInfoComponent();
    this.languageList = new LanguageListComponent();

    this.username = '';
    this.languages = [];
    this.totalXP = 0;
    this.column = 12;

    this.el = el('div.user-view', {column: this.column}, this.info, this.languageList);
  }

  update({username, languages, total_xp, amount_getter}) {
    this.username = username;
    this.languages = languages;
    this.totalXP = total_xp;

    this.el.setAttribute('column', Math.max(TOTAL_COLUMNS / amount_getter(), 3));
    this.info.update(this.username, this.totalXP);
    this.languageList.update(this.languages);
  }
}

export default UserViewComponent;
