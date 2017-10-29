import {el, list} from 'redom';

import UserViewComponent from './user-view.component';

class BattleGridComponent {
  constructor(socket, log) {
    this.socket = socket;
    this.log = log;

    this.el = list(el('div', {grid: 'row wrap'}), UserViewComponent);
    this.socket.connect();

    this.users = [];
    this.battleMode = false;
  }

  addUser(user) {
    this.log.addText(`Adding user ${user}...`);

    const channel = this.socket.channel(`users:${user}`);
    channel.join().receive('ok', init_data => {
      // If this was a reconnect, skip the data
      if (this.users.findIndex(u => u.username === user) !== -1) {
        return;
      }

      this.users.push({
        username: user,
        channel: channel,
        total_xp: init_data.total.xp,
        languages: init_data.languages.map(({name, xp}) => {return {name, xp};}),
        amount_getter: () => this.users.length
      });
      this.log.addText(`User ${user} added.`);
      this.update();
    }).receive('error', resp => {
      console.error(resp);
      this.log.addText(`User ${user} not found or private.`);
    });

    channel.on('new_pulse', msg => this.newPulse(user, msg));
  }

  clearUsers() {
    for (const {username, channel} of this.users) {
      channel.leave().receive('ok', () => this.log.addText(`Closed ${username}.`));
    }

    this.users = [];
    this.battleMode = false;

    this.log.addText('Users cleared.');
    this.update();
  }

  startBattle() {
    this.battleMode = true;
    this.users = this.users.map(u => {
      u.total_xp = 0;
      u.languages = [];
      return u;
    });

    this.update();
  }

  newPulse(user, {xps}) {
    this.users = this.users.map(u => {
      if (u.username === user) {
        u.total_xp += xps.reduce((acc, {amount}) => acc + amount, 0);

        for (const {language, amount} of xps) {
          const i = u.languages.findIndex(l => l.name === language);

          if (i !== -1) {
            u.languages.splice(
              i,
              1,
              {name: language, xp: amount + u.languages[i].xp}
            );
          }
          else {
            u.languages.push({name: language, xp: amount});
          }

          this.log.addText(`${user} +${amount} ${language}`);
        }
      }

      return u;
    });

    this.update();
  }

  update() {
    this.el.update(this.users);
  }
}

export default BattleGridComponent;
