/**
 * Handles connecting to the profile page socket and sending updates to Elm.
 */

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

    this.username = document.getElementById('profile-username').dataset.name;

    this.initSocket();
    this.installElm();
  }

  initSocket() {
    this.socket.connect();

    this.channel = this.socket.channel(`users:${this.username}`, {});

    console.log(`Joining channel users:${this.username}…`);
    this.channel.join()
      .receive('ok', (init_data) => {
        console.log('Connection successful.');
        this.initializeElm(init_data);
      })
      .receive('error', (resp) => { console.log('Connection failed:', resp) });

    this.channel.on('new_pulse', (msg) => { this.newPulse(msg); });
  }

  clearDOM() {
    ProfilePageUpdater.clearChildren(document.getElementById('profile-elm-total-container'));
    ProfilePageUpdater.clearChildren(document.getElementById('profile-elm-main-container'));
  }

  installElm() {
    this.clearDOM();
    this.tu_app = Elm.Profile.TotalUpdater.embed(this.tu_div);
    this.mu_app = Elm.Profile.MainUpdater.embed(this.mu_div);
  }

  initializeElm(init_data) {
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
