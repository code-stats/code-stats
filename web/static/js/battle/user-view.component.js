import {el} from 'redom';

import UserInfoComponent from './user-info.component';
import LanguageListComponent from './language-list.component';

class UserViewComponent {
  constructor() {
    this.info = new UserInfoComponent();
    this.languageList = new LanguageListComponent();

    this.el = el('div.user-view', {column: '3'}, this.info, this.languageList);

    this.username = '';
    this.languages = [];
    this.totalXP = 0;
  }

  update({username, languages, total_xp}) {
    this.username = username;
    this.languages = languages;
    this.totalXP = total_xp;

    this.info.update(this.username, this.totalXP);
    this.languageList.update(this.languages);
  }
}

export default UserViewComponent;
