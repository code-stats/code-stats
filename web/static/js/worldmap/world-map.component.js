import {el, list} from 'redom';
import PulseComponent from './pulse.component';

// Add this to coordinates to make them start from 0°
const LAT_TRANSFORM = 90;
const LON_TRANSFORM = 180;

// Then the max is this
const LAT_MAX = LAT_TRANSFORM * 2;
const LON_MAX = LON_TRANSFORM * 2;

/**
 * How long until to hide a pulse from the map with fade out.
 */
const HIDE_TIMER = 100;

/**
 * How long until to delete the pulse DOM element, after hiding it.
 */
const DELETE_TIMER = 4000;

/**
 * A graph that displays the world map and shows pulses of light where incoming XP was coded.
 */
class WorldMapGraphComponent {
  constructor() {
    this.pulseInput = [];
    this.pulseList = list('div.pulses', PulseComponent, 'id');

    this.el = el(
      'div.world-map',
      el('img.graph', {
        src: '/images/worldmap-colored_crushed.png',
        alt: 'World map with light pulses showing where users are coding'
      }),
      this.pulseList
    );

    // A counter to keep track of the elements to delete the correct DOM elements when
    // the timer is fired.
    this.pulseId = 0;
  }

  /**
   * Add a new pulse to the map. The first argument must be the coordinates as a map with
   * keys (lat,lon), the second argument is the integer amount of XP gained.
   */
  addPulse({lat, lon}, amount) {
    const id = ++this.pulseId;

    this.pulseInput.unshift(
      {lat, lon, amount, id, deleted: false}
    );

    this.update();

    // Hide pulse after a while
    setTimeout(() => this._hide(id), HIDE_TIMER);
  }

  /**
   * Force update the map. This is called internally.
   */
  update() {
    const pulseData = this.pulseInput.map(({lat, lon, amount, id, deleted}) => {
      const {x, y} = this._coords2XY(lat, lon);
      return {x, y, amount, id, deleted};
    });
    this.pulseList.update(pulseData);
  }

  // Hide specified pulse, triggering the fade out transition
  _hide(id) {
    this.pulseInput = this.pulseInput.map(data => {
      if (data.id === id) {
        data.deleted = true;
      }

      return data;
    });

    this.update();

    // Delete pulse from DOM after transition
    setTimeout(() => this._deleteItem(id), DELETE_TIMER);
  }

  // Delete pulse from DOM entirely
  _deleteItem(id) {
    this.pulseInput = this.pulseInput.filter(data => data.id !== id);
    this.update();
  }

  _coords2XY(lat, lon) {
    // Since we are using plate carrée or equirectangular, no need to convert coordinates
    // from spherical to planar
    const w = this.el.clientWidth;
    const h = this.el.clientHeight;

    const x = Math.round(((lon + LON_TRANSFORM) / LON_MAX) * w, 0);
    const y = h - Math.round(((lat + LAT_TRANSFORM) / LAT_MAX) * h, 0);
    return {x, y};
  }
}

export default WorldMapGraphComponent;
