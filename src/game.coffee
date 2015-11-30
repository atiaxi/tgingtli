Emitter = require('./emitter.coffee')

TILE_SIZE = 32
BOARD_WIDTH = 12
BOARD_HEIGHT = 12
# BOARD_WIDTH = 4
# BOARD_HEIGHT =3


class Selector extends Phaser.Group
  constructor: (@game, @cursor) ->
    super(@game)
    @selected = 1
    @onSelect = new Phaser.Signal
    @setup()

  setup: ->
    @keys = @game.input.keyboard.addKeys
      'w': Phaser.KeyCode.W,
      'a': Phaser.KeyCode.A,
      's': Phaser.KeyCode.S,
      'd': Phaser.KeyCode.D

    @keys.w.onDown.add =>
      @select(1)
    @keys.d.onDown.add =>
      @select(2)
    @keys.s.onDown.add =>
      @select(3)
    @keys.a.onDown.add =>
      @select(4)

  select: (number) ->
    @selected = number
    @onSelect.dispatch(number)


class Grid extends Phaser.Group

  constructor: (@game) ->
    super @game
    @setup()

  setup: ->
    # Set up the blank tilemap for the board.
    # Can't add tilemap directly to group because of reasons.
    # tilemaps are messed up.
    @map = @game.add.tilemap()
    @map.addTilesetImage 'map', 'map', TILE_SIZE, TILE_SIZE

    @layer1 = @map.create 'grid',
      BOARD_WIDTH, BOARD_HEIGHT, TILE_SIZE, TILE_SIZE

    @layer1.fixedToCamera = false;
    x = @game.width / 2 - @layer1.width / 2
    y = @game.height / 2 - @layer1.height / 2
    @layer1.position.set x, y

    # Fill the tilemap up with blanks
    @map.putTile(0, x, y, @layer1) for x in [0...BOARD_WIDTH] \
      for y in [0...BOARD_HEIGHT]

    @influences =
      0 for _ in [0...BOARD_HEIGHT] for _ in [0...BOARD_WIDTH]

    console.log(@influences)

    # Emitter will use some of this info
    @widthInTiles = BOARD_WIDTH
    @heightInTiles = BOARD_HEIGHT
    @pixelsPerTile = TILE_SIZE

    @addSinks()
    self

  addSinks: ->
    x = Math.floor BOARD_WIDTH / 2
    y = Math.floor BOARD_HEIGHT / 2

    @influences[x][y] = 5
    console.log x, y
    @map.putTile 5, x, y, @layer1

  cursorPos: ->
    @tileToPixel @cursorTilePos()...

  cursorTilePos: ->
    pointerX = @game.input.activePointer.worldX
    pointerY = @game.input.activePointer.worldY

    [tileX, tileY] = @pixelToTile(pointerX, pointerY)
    tileX = 0 if tileX < 0
    tileX = BOARD_WIDTH - 1 if tileX >= BOARD_WIDTH
    tileY = 0 if tileY < 0
    tileY = BOARD_HEIGHT - 1 if tileY >= BOARD_HEIGHT
    return [tileX, tileY]

  isOutOfBounds: (tileX, tileY) ->
    return true if tileX < 0 or tileX >= BOARD_WIDTH
    return true if tileY < 0 or tileY >= BOARD_HEIGHT
    return false

  momentumChangeForToken: (token) ->
    influence = @influences[token.momentum.x][token.momentum.y]
    return token.momentum unless influence
    result =
      x: token.momentum.x,
      y: token.momentum.y,
      dx: 0,
      dy: 0
    switch influence
      when 1 then result.dy = -1
      when 2 then result.dx = 1
      when 3 then result.dy = 1
      when 4 then result.dx = -1
      when 5
        result.dx = 3
        token.kill()
    return result


  pixelToTile: (pixelX, pixelY) ->
    # Offset pixel locs by current loc
    # Can't use built in getTileX because they assume tilemap
    # never moves away from 0,0
    pixelX -= @layer1.x
    pixelY -= @layer1.y
    tileX = Math.floor(pixelX / TILE_SIZE)
    tileY = Math.floor(pixelY / TILE_SIZE)

    return [tileX, tileY]

  placeTileAtCursor: (tileNum) ->
    [tileX, tileY] = @cursorTilePos()
    @map.putTile tileNum, tileX, tileY, @layer1
    @influences[tileX][tileY] = tileNum

  tileToPixel: (tileX, tileY) ->
    pixelX = @layer1.x + (tileX * TILE_SIZE)
    pixelY = @layer1.y + (tileY * TILE_SIZE)
    return [pixelX, pixelY]


class GameState extends Phaser.State

  addEmitter: ->
    # For now, we're just going to put them in the upper left
    emitX = -2
    emitY = 0

    emitter = new Emitter @game, emitX, emitY, @grid
    @game.add.existing emitter

  create: ->
    @grid = new Grid(@game)
    #@grid.create()
    @game.add.existing @grid

    # Arrows to follow the mouse around
    @cursor = @game.add.sprite 0, 0, 'map_sprites', 1

    @selector = new Selector @game, @cursor
    @selector.onSelect.add (number) =>
      @cursor.frame = number
    @game.add.existing @selector

    # Start us off
    @addEmitter()

  update: ->
    [x, y] = @grid.cursorPos()
    @cursor.x = x
    @cursor.y = y

    if @game.input.activePointer.isDown
      @grid.placeTileAtCursor(@cursor.frame)

module.exports = GameState
