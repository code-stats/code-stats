import profile_page from './profile_page';
import machine_page from './machine_page';

/**
 * List of routes. Key should be regex to match against path, value
 * should be function to execute.
 *
 * First matching route is executed.
 */
const ROUTES = [
  [/^\/users\/[^/]+\/?/, profile_page],
  [/^\/my\/machines\/?/, machine_page]
];

/**
 * The router executes the correct code based on the current path.
 */
class Router {
  constructor() {
    this.path = window.location.pathname;
  }

  execute() {
    for (const route of ROUTES) {
      if (route[0].test(this.path)) {
        route[1]();
        return;
      }
    }
  }
}

export default Router;
