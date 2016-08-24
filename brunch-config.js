exports.config = {
  // See http://brunch.io/#documentation for docs.
  files: {
    javascripts: {
      joinTo: {
        'js/app.js': /^(web\/static\/vendor)|(node_modules)|(web\/static\/js\/)|(web\/static\/elm-bin\/)/
      }

      // To use a separate vendor.js bundle, specify two files path
      // https://github.com/brunch/brunch/blob/stable/docs/config.md#files
      // joinTo: {
      //  "js/app.js": /^(web\/static\/js)/,
      //  "js/vendor.js": /^(web\/static\/vendor)|(deps)/
      // }
      //
      // To change the order of concatenation of files, explicitly mention here
      // https://github.com/brunch/brunch/tree/master/docs#concatenation
      // order: {
      //   before: [
      //     "web/static/vendor/js/jquery-2.1.1.js",
      //     "web/static/vendor/js/bootstrap.min.js"
      //   ]
      // }
    },
    stylesheets: {
      joinTo: {
        'css/app.css': /^web\/static\/css\/app\.scss$/,
      }
    },
    templates: {
      joinTo: 'js/app.js'
    }
  },

  conventions: {
    // This option sets where we should place non-css and non-js assets in.
    // By default, we set this to "/web/static/assets". Files in this directory
    // will be copied to `paths.public`, which is "priv/static" by default.
    assets: /^(web\/static\/assets)/
  },

  // Phoenix paths configuration
  paths: {
    // Dependencies and current project directories to watch
    watched: [
      'web/static',
      'test/static',
      'web/static/elm'
    ],

    // Where to compile files to
    public: 'priv/static'
  },

  // Configure your plugins
  plugins: {
    babel: {
      // Do not use ES6 compiler in vendor or elm code
      ignore: [/web\/static\/vendor/, /web\/static\/elm-bin/],
      presets: ['es2015', 'es2016']
    },

    sass: {
      mode: 'native',

      // Bootstrap needs higher precision to match precompiled pixel values
      precision: 8,
      options: {
        includePaths: [
          'node_modules/bootstrap-sass/assets/stylesheets'
        ]
      }
    },

    elmBrunch: {
      // This is relative to the `elmFolder` below
      executablePath: '../../../node_modules/elm/binwrappers',

      elmFolder: 'web/static/elm',
      mainModules: ['IndexPage/Updater.elm', 'Profile/MainUpdater.elm', 'Profile/TotalUpdater.elm'],

      // Compile elm files into elm-bin where they can be picked up from by the
      // javascript compiler
      outputFolder: '../elm-bin',

      // Compile all Elm main files into single JS file
      outputFile: 'elm-app.js'
    }
  },

  modules: {
    autoRequire: {
      'js/app.js': ['web/static/js/app']
    }
  },

  npm: {
    enabled: true,
    // Whitelist the npm deps to be pulled in as front-end assets.
    // All other deps in package.json will be excluded from the bundle.
    whitelist: ['phoenix', 'phoenix_html']
  },

  conventions: {
    // Don't scan for javascript files inside elm-stuff folders
    ignored: [/elm-stuff/]
  }
};
