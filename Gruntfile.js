/*global module:false*/
module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    // Metadata.
    pkg: grunt.file.readJSON('package.json'),
    banner: '/*! <%= pkg.title || pkg.name %> - v<%= pkg.version %> - ' +
      '<%= grunt.template.today("yyyy-mm-dd") %>\n' +
      '<%= pkg.homepage ? "* " + pkg.homepage + "\\n" : "" %>' +
      '* Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author.name %>;' +
      ' Licensed <%= _.pluck(pkg.licenses, "type").join(", ") %> */\n',
    // Task configuration.
    coffeeify: {
      options: {
        banner: '<%= banner %>',
        stripBanners: true,
        debug: true,
        watch: true,
        keepAlive: true,
      },
      dev: {
        src: ['src/index.coffee', 'src/*.coffee'],
        dest: 'dist/lib/<%= pkg.name %>.js'
      }
    },

    watch: {
      scripts: {
        files: ['src/**/*.coffee'],
        tasks: ['coffeeify']
      }
    }
  });

  // These plugins provide necessary tasks.
  grunt.loadNpmTasks('grunt-coffeeify');
  grunt.loadNpmTasks('grunt-contrib-watch');

  // Default task.
  grunt.registerTask('default', ['coffeeify']);

};
