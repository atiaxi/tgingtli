
class InstructionsState extends Phaser.State

  create: ->
    @bg = @game.add.sprite 0, 0, @key

  init: (@key='instructions_screen') ->

  nextState: ->
    @game.state.start 'title'

  update: ->
    @nextState() if @game.input.activePointer.isDown

module.exports = InstructionsState
