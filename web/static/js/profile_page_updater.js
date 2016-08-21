/**
 * Handles connecting to the profile page socket and sending updates to Elm.
 */

import LevelProgress from './level_progress';
import ProgressBar from './progress_bar';
import Elm from '../elm-bin/elm-app';

class ProfilePageUpdater {
  constructor(socket) {
    this.socket = socket;
    this.channel = null;

    this.username = null;

    this.total_progress = null;
    this.language_progresses = [];
    this.machine_progresses = [];

    // Elm app containers
    this.tu_div = document.getElementById('profile-elm-total-container');
    this.mu_div = document.getElementById('profile-elm-main-container');

    // Elm apps
    this.tu_app = null;
    this.mu_app = null;

    this.parseElems();
    this.initSocket();
    this.clearDOM();
    this.installElm();
    this.initializeElm();
  }

  parseElems() {
    this.username = document.getElementById('profile-username').dataset.name;

    const total_progress_elem = document.getElementById('profile-elm-total-container');
    this.total_progress = {
      xp: parseInt(total_progress_elem.dataset.xp),
      new_xp: parseInt(total_progress_elem.dataset.recentXp)
    };

    const language_elems = document.getElementsByClassName('profile-language-progress');
    for (const elem of language_elems) {
      this.language_progresses.push({
        name: elem.dataset.name,
        xp: parseInt(elem.dataset.xp),
        new_xp: parseInt(elem.dataset.recentXp)
      });
    }

    const more_language_elems = document.getElementsByClassName('profile-more-language-progress');
    for (const elem of more_language_elems) {
      this.language_progresses.push({
        name: elem.dataset.name,
        xp: parseInt(elem.dataset.xp),
        new_xp: parseInt(elem.dataset.recentXp)
      });
    }

    const machine_elems = document.getElementsByClassName('profile-machine-progress');
    for (const elem of machine_elems) {
      this.machine_progresses.push({
        name: elem.dataset.name,
        xp: parseInt(elem.dataset.xp),
        new_xp: parseInt(elem.dataset.recentXp)
      });
    }
  }

  initSocket() {
    this.socket.connect();

    this.channel = this.socket.channel(`users:${this.username}`, {});

    console.log(`Joining channel users:${this.username}…`);
    this.channel.join()
      .receive('ok', () => { console.log('Connection successful.'); })
      .receive('error', (resp) => { console.log('Connection failed:', resp) });

    this.channel.on('new_pulse', (msg) => { this.newPulse(msg); });
  }

  clearDOM() {
    ProfilePageUpdater.clearChildren(document.getElementById('profile-elm-total-container'));
    ProfilePageUpdater.clearChildren(document.getElementById('profile-elm-main-container'));
  }

  installElm() {
    this.tu_app = Elm.Profile.TotalUpdater.embed(this.tu_div);
    this.mu_app = Elm.Profile.MainUpdater.embed(this.mu_div);
  }

  initializeElm() {
    const init_data = {
      total: this.total_progress,
      languages: this.language_progresses,
      machines: this.machine_progresses
    };

    this.tu_app.ports.tu_initialize.send(init_data);
    this.mu_app.ports.mu_initialize.send(init_data);
  }

  newPulse(msg) {
    this.tu_app.ports.tu_new_xp.send(msg);
    this.mu_app.ports.mu_new_xp.send(msg);
  }

  static clearChildren(elem) {
    while (elem.lastChild) {
      elem.removeChild(elem.lastChild);
    }
  }
}

export default ProfilePageUpdater;
