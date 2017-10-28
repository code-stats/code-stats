import {el} from 'redom';

class ProgressCounterComponent {
  constructor(el_type) {
    this.el = el(el_type + '.xp-counter');

    this.xp = 0;
  }

  update(xp) {
    this.xp = xp;
    this.el.textContent = xp.toLocaleString() + ' XP';
  }
}

export default ProgressCounterComponent;
