
class GameOverState extends Phaser.State

  create: ->
    style =
      font: 'bold 64px Arial',
      fill: '#FFF'

    @text = @game.add.text @game.width / 2, @game.height / 2,
      "Game Over", style
    @text.anchor.set 0.5, 0.5

module.exports = GameOverState
