/**
 * Code to execute on index page.
 */

import { get_live_update_socket } from '../../common/js/utils';
import IndexPageUpdater from './index_page_updater';

let updater = null;

function index_page() {
  updater = new IndexPageUpdater(get_live_update_socket());
}

export default index_page;
