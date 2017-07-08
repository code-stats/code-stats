import {el} from 'redom';

/**
 * Max diameter of pulse circle in pixels
 */
const MAX_SIZE = 20;

/**
 * Min diameter of pulse circle in pixels
 */
const MIN_SIZE = 10;

/**
 * This amount and over of XP will get max circle size
 */
const MAX_AMOUNT = 100;

/**
 * A single pulse on the world map.
 */
class PulseComponent {
  constructor() {
    this.el = el('div.pulse-indicator');
  }

  update({x, y, amount, deleted}) {
    amount = Math.min(MAX_AMOUNT, amount);
    const percentage = amount / MAX_AMOUNT;
    const diameter = (((MAX_SIZE - MIN_SIZE) * percentage) / 1) + MIN_SIZE;

    const newX = x - Math.floor(diameter / 2);
    const newY = y - Math.floor(diameter / 2);

    this.el.style.left = `${newX}px`;
    this.el.style.top = `${newY}px`;
    this.el.style.width = `${diameter}px`;
    this.el.style.height = `${diameter}px`;

    if (deleted) {
      this.el.className += ' hidden-fadeout';
    }
  }
}

export default PulseComponent;
