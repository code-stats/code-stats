// Import Babel polyfill to fix functionality for silly browsers
//import 'babel-polyfill';

import {get_live_update_socket} from './utils';

import {mount} from 'redom';
import LogComponent from './battle/log.component';
import BattleGridComponent from './battle/battle-grid.component';

document.addEventListener('DOMContentLoaded', () => {
  const socket = get_live_update_socket();

  const log_el = document.getElementById('log');
  const log = new LogComponent();
  mount(log_el, log);

  const el = document.getElementById('battle-grid');
  const grid = new BattleGridComponent(socket, log);
  mount(el, grid);

  const add_user_button_el = document.getElementById('add-user-button');
  const start_battle_button_el = document.getElementById('start-battle-button');

  add_user_button_el.addEventListener('click', () => {
    const user = prompt('Enter username');

    if (user) {
      grid.addUser(user);
    }
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
      start_battle_button_el.parentNode.removeChild(start_battle_button_el);
    }, 5000);
  });
});
