import {mount} from 'redom';
import WorldMapGraphComponent from './worldmap/world-map.component';

/**
 * Handles connecting to the index page socket and sending updates to the graphs.
 */
class IndexPageUpdater {
  constructor(socket) {
    this.socket = socket;
    this.channel = null;

    this.worldMapEl = document.getElementById('world-map-graph');
    this.worldMap = new WorldMapGraphComponent();
    mount(this.worldMapEl, this.worldMap);

    this.initSocket();
  }

  initSocket() {
    this.socket.connect();

    this.channel = this.socket.channel('frontpage', {});

    console.debug('Joining channel frontpage…');
    this.channel.join()
      .receive('ok', init_data => {
        console.debug('Connection successful.');
        this.initialize(init_data);
      })
      .receive('error', (resp) => { console.error('Connection failed:', resp); });

      this.channel.on('new_pulse', (msg) => { this.newPulse(msg); });
  }

  initialize(init_data) {
  }

  newPulse({xps, coords}) {
    for (const {language, xp} of xps) {
      if (coords != null) {
        this.worldMap.addPulse(coords, xp);
      }
    }
  }
}

export default IndexPageUpdater;
