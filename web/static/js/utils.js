/**
 * Miscellaneous utilities.
 */

import { Socket } from "phoenix";

/**
 * Format given XP as nice human readable number.
 */
function format_xp(xp) {
  return xp.toLocaleString('en-US');
}

/**
 * Get live update socket for the correct backend socket path.
 *
 * Authenticates with token if available.
 */
function get_live_update_socket() {
  const meta_tag = document.getElementsByName('channel_token');

  let data = {params: {}};
  if (meta_tag.length === 1) {
    data.token = meta_tag[0].content;
    console.log('Authentication exists, generating socket with token', data.token);
  }

  return new Socket('/live_update_socket', data);
}

export { format_xp, get_live_update_socket };
