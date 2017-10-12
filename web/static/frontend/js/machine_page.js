/**
 * Code to execute on machines page.
 * 
 * - Enables clipboard.js for "Copy" buttons
 * - Makes API key inputs select all text on click
 * - Adds prompt for deleting machines
 */

import Clipboard from 'clipboard';

function machine_page() {
  const clipboard = new Clipboard('.copy-to-clipboard');
  clipboard.on('success', (event) => {
    event.trigger.innerText = 'Copied!';
    event.clearSelection();
  });

  document.addEventListener('DOMContentLoaded', () => {
    const apiKeys = document.getElementsByClassName('api-key');
    for (const input of apiKeys) {
      input.onclick = (event) => event.target.select();
    }

    const buttons = document.getElementsByClassName('machine-delete-button');
    for (const button of buttons) {
      button.onclick = () => {
        return confirm('Are you sure you wish to delete this machine? You will lose all XP associated with it.');
      };
    }
  });
}

export default machine_page;
