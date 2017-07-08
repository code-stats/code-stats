/**
 * Code to execute on profile pages.
 */

import { get_live_update_socket } from '../../common/js/utils';
import ProfilePageUpdater from './profile_page_updater';

let updater = null;

function profile_page() {
  // If user has just registered (has no XP), the main Elm container won't exist.
  // In that case, live updates will be disabled.
  const elm_main_container = document.getElementById('profile-elm-main-container');
  if (elm_main_container == null) {
    return;
  }

  updater = new ProfilePageUpdater(get_live_update_socket());
}

export default profile_page;
