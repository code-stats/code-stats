import {get_live_update_socket} from '../../common/js/utils';

import {mount} from 'redom';
import LogComponent from './log.component';
import BattleGridComponent from './battle-grid.component';

function parseHash() {
  const hash = window.location.hash;

  if (hash.length > 2 && hash[0] === '#' && hash[1] === '/') {
    return hash.substr(1).split('/')
    .filter(str => str !== '')
    .map(username => decodeURIComponent(username));
  }
  else {
    return [];
  }
}

function setHash(users) {
  window.location.hash = '#/' + users.map(u => encodeURIComponent(u)).join('/');
}

document.addEventListener('DOMContentLoaded', () => {
  const socket = get_live_update_socket();

  const log_el = document.getElementById('log');
  const log = new LogComponent();
  mount(log_el, log);

  const el = document.getElementById('battle-grid');
  const grid = new BattleGridComponent(socket, log);
  mount(el, grid);

  const add_user_button_el = document.getElementById('add-user-button');
  const clear_users_button_el = document.getElementById('clear-users-button');
  const start_battle_button_el = document.getElementById('start-battle-button');

  function initFromHash() {
    const users = parseHash();

    if (users.length > 0) {
      log.addText('Loading users from hash...');
      for (const user of users) {
        grid.addUser(user);
      }
    }
  }

  initFromHash();

  add_user_button_el.addEventListener('click', () => {
    const user = prompt('Enter username');

    if (user) {
      setHash(grid.users.map(({username}) => username).concat(user));
    }
  });

  clear_users_button_el.addEventListener('click', () => {
    if (confirm('Are you sure you want to clear all users?')) setHash([]);
  });

  start_battle_button_el.addEventListener('click', () => {
    if (grid.users.length === 0) {
      log.addText('You need at least 2 combatants!');
      return;
    }

    log.addText('Starting battle in 5...');

    setTimeout(() => log.addText('4...'), 1000);
    setTimeout(() => log.addText('3...'), 2000);
    setTimeout(() => log.addText('2...'), 3000);
    setTimeout(() => log.addText('1...'), 4000);
    setTimeout(() => {
      log.addText('The battle is on!');
      grid.startBattle();
      start_battle_button_el.setAttribute('disabled', 'disabled');
    }, 5000);
  });

  window.addEventListener('hashchange', () => {
    log.addText('Hash changed, restarting.');
    grid.clearUsers();
    start_battle_button_el.removeAttribute('disabled');
    initFromHash();
  });
});
