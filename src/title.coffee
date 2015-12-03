

class TitleState extends Phaser.State

  create: ->
    @bg = @game.add.sprite 0, 0, 'title_screen'

    style =
      font: '32px Unique',
      fill: '#fff'

    x = @game.width / 2
    y = @game.height / 2

    @start_button = @game.add.button x, y,
      'start_button', @nextState, this, 0, 1, 1, 1
    @start_button.anchor.setTo 0, 1

    instructions = @game.add.button x, y,
      'instructions', @instructions, this, 0, 1, 1, 1

    credits = @game.add.button x, y + 65,
      'credits_button', @credits, this, 0, 1, 1, 1

    unless @game.pamgaea_music
      @game.pamgaea_music = @game.add.audio 'bgmusic', 1, true
      @game.pamgaea_music.play()

  instructions: ->
    @game.state.start 'instructions_state'

  credits: ->
    @game.state.start 'instructions_state', true, false, 'credits'

  nextState: ->
    @game.state.start 'playing', true, false, 1


module.exports = TitleState
