import {el} from 'redom';

class LogComponent {
  constructor() {
    this.text = '';

    this.el = el(
      'textarea',
      {
        rows: 4,
        readonly: 'readonly',
        style: {
          border: 0,
          resize: 'none',
          overflow: 'hidden',
          margin: 0,
          padding: 0
        }
      }
    );
  }

  addText(text) {
    this.text += "\n" + text;
    this.update();
  }

  update() {
    this.el.value = this.text;
    this.el.scrollTop = this.el.scrollHeight;
  }
}

export default LogComponent;
