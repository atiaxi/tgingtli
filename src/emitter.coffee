
class Token extends Phaser.Sprite
  constructor: (@game, @grid, @momentum, frame) ->
    [ @pixelX, @pixelY ] = @grid.tileToPixel @momentum.x, @momentum.y
    super @game, @pixelX, @pixelY, 'map_sprites', frame
    @nextTile()

  adopt: (@momentum, @frame) ->
    [ @pixelX, @pixelY ] = @grid.tileToPixel @momentum.x, @momentum.y
    @reset @pixelX, @pixelY
    @nextTile()

  nextTile: ->
    @nextX = @momentum.dx + @momentum.x
    @nextY = @momentum.dy + @momentum.y
    [ npx, npy ] = @grid.tileToPixel @nextX, @nextY
    # Tried re-using the tween but there's a strange issue where it'll start
    # tweening from where it originally began instead of its new location.
    # Will keep doing this way unless performance becomes a problem
    @tween = @game.add.tween this
    @tween.to {x: npx, y: npy}, 200
    @tween.onComplete.addOnce( =>
      @momentum.x = @nextX
      @momentum.y = @nextY
      if @grid.isOutOfBounds @momentum.x, @momentum.y
        @grid.state.addProgress -1
        this.kill()
      else
        @momentum = @grid.momentumChangeForToken this
        @nextTile() if @alive
    )
    @tween.start()

class Emitter extends Phaser.Group
  constructor: (@game, @tileX, @tileY, @grid) ->
    super(@game)
    @emits = 5
    @timeBetweenEmissions = 2
    @nextEmission = 2

    @momentum = dx: 1, dy: 0, x: @tileX, y: @tileY

    [ @pixelX, @pixelY ] = @grid.tileToPixel @tileX, @tileY

    @setup()

  emit: ->
    @nextEmission += @timeBetweenEmissions
    #@nextEmission = 100000
    momentum =
      x: @momentum.x + 1,
      y: @momentum.y,
      dx: @momentum.dx,
      dy: @momentum.dy
    recycle = @getFirstDead()
    if recycle
      recycle.adopt momentum, @emits
    else
      token = new Token @game, @grid, momentum, @emits, this
      @add token

  setup: ->
    @sprite = @game.add.sprite @pixelX, @pixelY, 'map_sprites', 5, this

  update: ->
    @nextEmission -= @game.time.physicsElapsed
    @emit() if @nextEmission <= 0

module.exports = Emitter
