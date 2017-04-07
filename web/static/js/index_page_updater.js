import { clear_children } from './utils';

/**
 * Handles connecting to the index page socket and sending updates to Elm.
 */
class IndexPageUpdater {
  constructor(socket) {
    this.socket = socket;
    this.channel = null;

    // Elm app container
    this.iu_div = document.getElementById('index-elm-container');
    this.iu_app = null;

    this.initSocket();
  }

  initSocket() {
    this.socket.connect();

    this.channel = this.socket.channel('frontpage', {});

    console.log('Joining channel frontpage…');
    this.channel.join()
      .receive('ok', (init_data) => {
        console.log('Connection successful.');
        this.initializeElm(init_data);
      })
      .receive('error', (resp) => { console.log('Connection failed:', resp) });

      this.channel.on('new_pulse', (msg) => { this.newPulse(msg); });
  }

  clearDOM() {
    clear_children(this.iu_div);
  }

  initializeElm(init_data) {
    this.iu_app.ports.iu_initialize.send(init_data);
  }

  newPulse(msg) {
    for (const xp of msg.xps) {
      this.iu_app.ports.iu_new_xp.send(xp);
    }
  }
}

export default IndexPageUpdater;
