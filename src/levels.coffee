
class LevelsState extends Phaser.State

  init: (@number) ->

  create: ->
    @bg = @game.add.sprite 0, 0, 'bg'

    bigstyle =
      font: 'bold 64px Unique',
      fill: '#FFF'

    @text = @game.add.text @game.width / 2, @game.height / 2,
      "Level #{@number}", bigstyle
    @text.anchor.set 0.5, 0.5

    style =
      font: '32px Unique',
      fill: '#fff'

    @start = @game.add.text @game.width / 2, @game.height - 10,
      "Click to start loading", style
    @start.anchor.set 0.5, 1

  nextState: ->
    @game.state.start 'playing', true, false, @number

  update: ->
    @nextState() if @game.input.activePointer.isDown

module.exports = LevelsState
