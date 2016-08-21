/**
 * Code to execute on profile pages.
 */

import { get_live_update_socket } from './utils';
import ProfilePageUpdater from './profile_page_updater';

let updater = null;

function profile_page() {
  updater = new ProfilePageUpdater(get_live_update_socket());
}

export default profile_page;
