GameState = require("./game.coffee");


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

    # TODO: All the stuff to preload
    #@load.image 'whitesquare', 'assets/whitesquare.png'
    @load.image 'map', 'assets/map.png'
    # Our tile map are also our sprites
    @load.spritesheet 'map_sprites', 'assets/map.png', 32, 32


  create: ->
    @game.state.start 'playing'

main = ->
  game = new Phaser.Game 800, 650, Phaser.AUTO, 'game'

  game.state.add 'boot', BootState
  game.state.add 'preload', PreloadState
  game.state.add 'playing', GameState

  game.state.start 'boot'

# ENTRY POINT
window.onload = ->
  main()
