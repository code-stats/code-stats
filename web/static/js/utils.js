/**
 * Miscellaneous utilities.
 */

import { Socket } from "phoenix";

/**
 * Get live update socket for the correct backend socket path.
 *
 * Authenticates with token if available.
 */
function get_live_update_socket() {
  const meta_tag = document.getElementsByName('channel_token');

  let data = {params: {}};
  if (meta_tag.length === 1) {
    data.params.token = meta_tag[0].content;
    console.log('Authentication exists, generating socket with token', data.params.token);
  }

  return new Socket('/live_update_socket', data);
}

/**
 * Destroy all of a DOM element's children.
 */
function clear_children(elem) {
  while (elem.lastChild) {
    elem.removeChild(elem.lastChild);
  }
}

export { get_live_update_socket, clear_children };
