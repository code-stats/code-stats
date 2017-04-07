import sourcemaps from 'rollup-plugin-sourcemaps';
import resolve from 'rollup-plugin-node-resolve';
import commonjs from 'rollup-plugin-commonjs';

export default {
  plugins: [
    sourcemaps(),
    resolve(),
    commonjs({
      namedExports: {
        'node_modules/phoenix/priv/static/phoenix.js': ['Socket']
      }
    })
  ]
};
