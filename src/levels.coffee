
class LevelsState extends Phaser.State

  init: (@number) ->

  create: ->
    style =
      font: 'bold 64px Unique',
      fill: '#FFF'

    @text = @game.add.text @game.width / 2, @game.height / 2,
      "Level #{@number}", style
    @text.anchor.set 0.5, 0.5

module.exports = LevelsState
