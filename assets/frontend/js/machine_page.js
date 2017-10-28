/**
 * Code to execute on machines page. Adds prompt for deleting machines.
 */

function machine_page() {
  document.addEventListener('DOMContentLoaded', () => {
    const buttons = document.getElementsByClassName('machine-delete-button');

    for (const button of buttons) {
      button.onclick = () => {
        return confirm('Are you sure you wish to delete this machine? You will lose all XP associated with it.');
      };
    }

    const copy_buttons = document.getElementsByClassName('copy-button');

    for (const button of copy_buttons) {
      button.onclick = () => {
        button.parentElement.getElementsByClassName('api-key')[0].select();
        try {
          document.execCommand('copy');
          button.textContent = 'Copied!';
        }
        catch (e) {
          button.textContent = 'Error';
        }
      };
    }
  });
}

export default machine_page;
