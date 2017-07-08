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
  });
}

export default machine_page;
