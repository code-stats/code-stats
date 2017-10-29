import {mount} from 'redom';
import {clear_children} from '../../common/js/utils';
import MainInfoComponent from './profile/main_info.component';
import TotalInfoComponent from './profile/total_info.component';

/**
 * Handles connecting to the profile page socket and sending updates to the components.
 */
class ProfilePageUpdater {
  constructor(socket) {
    this.socket = socket;
    this.channel = null;

    this.username = document.getElementById('profile-username').dataset.name;

    // Component containers
    this.tu_div = document.getElementById('profile-total-container');
    this.mu_div = document.getElementById('main-stats-container');

    // Main components
    this.tu_app = new TotalInfoComponent(this.tu_div);
    this.mu_app = new MainInfoComponent();

    clear_children(this.mu_div);

    mount(this.mu_div, this.mu_app);

    this.initSocket();
  }

  initSocket() {
    this.socket.connect();

    this.channel = this.socket.channel(`users:${this.username}`, {});

    console.log(`Joining channel users:${this.username}…`);
    this.channel.join()
      .receive('ok', init_data => {
        console.log('Connection successful.');
        this.initialize(init_data);
      })
      .receive('error', (resp) => { console.error('Connection failed:', resp) });

    this.channel.on('new_pulse', (msg) => { this.newPulse(msg); });
  }

  initialize(init_data) {
    this.tu_app.initData(init_data);
    this.mu_app.initData(init_data);
  }

  newPulse(msg) {
    this.tu_app.update(msg);
    this.mu_app.update(msg);
  }
}

export default ProfilePageUpdater;
