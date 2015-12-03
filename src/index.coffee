TitleState = require('./title.coffee')
InstructionsState = require('./instructions.coffee')
GameState = require('./game.coffee')
GameOverState = require('./gameover.coffee')
LevelsState = require('./levels.coffee')

# We heard you liked preloaders, so we're preloading the
# preloading screen
class BootState extends Phaser.State
  preload: ->
    @load.image 'preloaderBg', 'assets/preload-empty.png'
    @load.image 'preloaderBar', 'assets/preload-full.png'

  create: ->
    @game.state.start 'preload'


class PreloadState extends Phaser.State
  preload: ->
    @preloadBg = @add.sprite @game.width / 2, @game.height / 2,
      'preloaderBg'
    @preloadBg.anchor.set 0.5

    @preloadBar = @add.sprite @game.width / 2, @game.height / 2,
      'preloaderBar'
    # This line is necessary because otherwise it fills from
    # the middle out, which looks kinda cool but is not what
    # we want.
    @preloadBar.x -= @preloadBar.width / 2
    @preloadBar.anchor.y = 0.5

    @load.setPreloadSprite @preloadBar

    @load.image 'bg', 'assets/bg.png'
    @load.image 'title_screen', 'assets/title.png'
    @load.image 'instructions_screen', 'assets/instructions_1.png'
    @load.image 'map', 'assets/map.png'
    # Our tile map are also our sprites
    @load.spritesheet 'map_sprites', 'assets/map.png', 32, 32
    @load.spritesheet 'instructions', 'assets/instructions_button.png', 330, 68
    @load.spritesheet 'start_button', 'assets/start_button_2.png', 200, 68
    @load.audio('bgmusic', ['assets/Pamgaea.mp3', 'assets/Pamgaea.ogg']);


  create: ->
    @game.state.start 'title'

main = ->
  game = new Phaser.Game 800, 650, Phaser.AUTO, 'game'

  game.state.add 'boot', BootState
  game.state.add 'preload', PreloadState
  game.state.add 'title', TitleState
  game.state.add 'instructions_state', InstructionsState
  game.state.add 'playing', GameState
  game.state.add 'levels', LevelsState
  game.state.add 'gameover', GameOverState

  game.state.start 'boot'

# ENTRY POINT
window.onload = ->
  main()
