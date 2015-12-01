
class TitleState extends Phaser.State

  create: ->
    @bg = @game.add.sprite 0, 0, 'title_screen'

    style =
      font: '32px Unique',
      fill: '#fff'

    @start = @game.add.text @game.width / 2, @game.height - 10,
      "Click to start loading", style
    @start.anchor.set 0.5, 1

  nextState: ->
    @game.state.start 'playing', true, false, 1

  update: ->
    @nextState() if @game.input.activePointer.isDown

module.exports = TitleState
