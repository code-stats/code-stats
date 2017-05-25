// Import dependencies

// Import Babel polyfill to fix functionality for silly browsers
//import 'babel-polyfill';

import 'phoenix_html';

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

import Router from './router';

const router = new Router();
router.execute();
