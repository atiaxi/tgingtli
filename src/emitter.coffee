
class Token extends Phaser.Sprite
  constructor: (@game, @grid, @momentum, frame) ->
    @phase = Math.floor (frame-1) / 5
    [ @pixelX, @pixelY ] = @grid.tileToPixel @momentum.x, @momentum.y
    super @game, @pixelX, @pixelY, 'map_sprites', frame
    @nextTile()

  adopt: (@momentum, @frame) ->
    @phase = Math.floor (@frame-1) / 5
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
  constructor: (@game, @grid, @momentum, @emits) ->
    super(@game)
    @timeBetweenEmissions = 2
    @nextEmission = 5
    @appearing = true
    @blinks = 0.5
    @nextBlink = 0.5

    [ @pixelX, @pixelY ] = @grid.tileToPixel @momentum.x, @momentum.y
    @setup()

  blink: ->
    @nextBlink = @blinks
    if @nextEmission < 0.5
      @appearing = false
      @visible = true
    else
      @visible = !@visible

  emit: ->
    @timeBetweenEmissions -= 0.001 if @timeBetweenEmissions > 0.5
    @nextEmission += @timeBetweenEmissions
    #@nextEmission = 100000
    momentum =
      x: @momentum.x + @momentum.dx,
      y: @momentum.y + @momentum.dy,
      dx: @momentum.dx,
      dy: @momentum.dy
    recycle = @getFirstDead()
    if recycle
      recycle.adopt momentum, @emits
    else
      token = new Token @game, @grid, momentum, @emits, this
      @add token

  setup: ->
    @sprite = @game.add.sprite @pixelX, @pixelY, 'map_sprites', @emits, this

  update: ->
    @nextEmission -= @game.time.physicsElapsed
    @emit() if @nextEmission <= 0
    if @appearing
      @nextBlink -= @game.time.physicsElapsed
      @blink() if @nextBlink < 0

module.exports = Emitter
