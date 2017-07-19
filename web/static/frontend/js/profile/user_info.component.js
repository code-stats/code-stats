import {el} from 'redom';

class UserInfoComponent {
  constructor(username, registered_at, last_day_coded) {
    this.el = el('div', [
      el('h2', username),
      el('ul.profile-detail-list', [
        el('li', [
          'User since ',
          el('time', registered_at, {datetime: registered_at}),
          '.'
        ]),
        el('li', [
          'Last programmed ',
          (last_day_coded != null) && el('time', last_day_coded, {datetime: last_day_coded}),
          (last_day_coded == null) && el('em', 'never'),
          '.'
        ])
      ])
    ]);
  }
}

export default UserInfoComponent;
