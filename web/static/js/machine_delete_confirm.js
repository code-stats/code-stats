/**
 * Adds prompt for deleting machines.
 */

document.addEventListener('DOMContentLoaded', () => {
  const buttons = document.getElementsByClassName('machine-delete-button');

  for (const button of buttons) {
    button.onclick = () => {
      return confirm('Are you sure you wish to delete this machine? You will lose all XP associated with it.');
    };
  }
});
