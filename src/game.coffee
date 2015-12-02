Emitter = require('./emitter.coffee')
utils = require('./utils.coffee')

TILE_SIZE = 32
BOARD_WIDTH = 12
BOARD_HEIGHT = 12
# BOARD_WIDTH = 4
# BOARD_HEIGHT =3
PHASES = 3

console.log utils
randInt = utils.randInt
randIndex = utils.randIndex
randFromArray = utils.randFromArray
takeRandFromArray = utils.takeRandFromArray
mod = utils.mod


class Selector extends Phaser.Group
  constructor: (@game, @cursor) ->
    super(@game)
    @phase = 0
    @selected = 1
    @dirSelected = 1
    @onSelect = new Phaser.Signal
    @setup()

  iconForPhase: (phase) ->
    phase = mod phase, PHASES
    phase * 5 + 5

  numberForPhase: (num) ->
    @phase * 5 + num

  phasedToDirection: (phased, context) ->
    return 0 if phased == 0
    phase = Math.floor (phased-1) / 5
    result = phased - phase * 5
    if context and context.phase != phase
      return -1 if result == 5  # Delivered to the wrong sink
      return 0
    result

  setup: ->
    @keys = @game.input.keyboard.addKeys
      'w': Phaser.KeyCode.W,
      'a': Phaser.KeyCode.A,
      's': Phaser.KeyCode.S,
      'd': Phaser.KeyCode.D,
      'q': Phaser.KeyCode.Q,
      'e': Phaser.KeyCode.E

    @keys.w.onDown.add =>
      @select(1)
    @keys.d.onDown.add =>
      @select(2)
    @keys.s.onDown.add =>
      @select(3)
    @keys.a.onDown.add =>
      @select(4)
    @keys.q.onDown.add =>
      @shift(-1)
    @keys.e.onDown.add =>
      @shift(1)

    col = (5 + TILE_SIZE * x for x in [0...3])
    row = (5 + TILE_SIZE * y for y in [0...4])

    style =
      font: "bold #{TILE_SIZE}px Unique",
      fill: "#fff"

    w_icon = @game.add.sprite col[1], row[1], 'map_sprites', 1
    w_letter = @game.add.text col[1], row[0], 'W', style
    a_icon = @game.add.sprite col[0], row[2], 'map_sprites', 4
    a_letter = @game.add.text col[0], row[3], 'A', style
    s_icon = @game.add.sprite col[1], row[2], 'map_sprites', 3
    s_letter = @game.add.text col[1], row[3], 'S', style
    d_icon = @game.add.sprite col[2], row[2], 'map_sprites', 2
    d_letter = @game.add.text col[2], row[3], 'D', style

    @q_icon = @game.add.sprite col[0], row[1], 'map_sprites', @iconForPhase(-1)
    q_letter = @game.add.text  col[0], row[0], 'Q', style
    @e_icon = @game.add.sprite col[2], row[1], 'map_sprites', @iconForPhase(1)
    e_letter = @game.add.text  col[2], row[0], 'E', style

    @icons = [w_icon, d_icon, s_icon, a_icon]

  shift: (direction) ->
    @phase = mod (@phase + direction), PHASES
    for icon, i in @icons
      icon.frame = @numberForPhase i+1

    @q_icon.frame = @iconForPhase(@phase - 1)
    @e_icon.frame = @iconForPhase(@phase + 1)

    # Let the cursor know we swapped palletes.
    @select @dirSelected

  select: (number) ->
    @dirSelected = number
    @selected = @numberForPhase number
    @onSelect.dispatch @selected


class Grid extends Phaser.Group

  constructor: (@game, @state) ->
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

    # Emitter will use some of this info
    @widthInTiles = BOARD_WIDTH
    @heightInTiles = BOARD_HEIGHT
    @pixelsPerTile = TILE_SIZE

    @addSinks()

    self

  addSinks: ->
    allX = (x for x in [2...BOARD_WIDTH-2])
    allY = (y for y in [2...BOARD_HEIGHT-2])
    # Purposely choosing locations this way so that sinks are guaranteed
    # to have a row and column to themselves

    placeSink = (frame) =>
      x = takeRandFromArray(allX)
      y = takeRandFromArray(allY)
      @influences[x][y] = frame
      @map.putTile frame, x, y, @layer1

      # Put an outline around them, so they can be spotted
      [px, py] = @tileToPixel x, y
      highlight = @game.add.sprite px, py, 'map_sprites', 0
      highlight.tint = 0x000000

    placeSink 5
    placeSink 10
    placeSink 15

  cursorPos: ->
    [tx, ty] = @cursorTilePos()
    [x, y] = @tileToPixel tx, ty
    influence = @influences[tx][ty] if @influences
    return [x, y, influence]

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
    influence = @state.selector.phasedToDirection influence, token
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
        @state.addProgress 1
        token.kill()
      when -1
        @state.addProgress -1
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
    @numEmitters += 1
    if @numEmitters >= @level
      @timeBetweenEmitters = 10

    @nextEmitter = @timeBetweenEmitters

    side = null
    until side
      side = randFromArray @choices

    chosen = takeRandFromArray side.choices

    momentum =
      x: chosen[0],
      y: chosen[1],
      dx: side.dx,
      dy: side.dy

    emitting = [randFromArray([5, 10, 15]), randFromArray [5, 10, 15]]

    emitter = new Emitter @game, @grid, momentum, emitting
    @game.add.existing emitter

  addProgress: (amount) ->
    @setProgress @progress + amount

  create: ->
    @bg = @game.add.sprite 0, 0, 'bg'

    @grid = new Grid(@game, this)
    #@game.add.existing @grid

    # Arrows to follow the mouse around
    @cursor = @game.add.sprite 0, 0, 'map_sprites', 1
    @cursor.alpha = 0.5

    @selector = new Selector @game, @cursor
    @selector.onSelect.add (number) =>
      @cursor.frame = number
    @game.add.existing @selector

    # The loading bar.  You know, the whole point.
    @progress = 0
    @barbg = @game.add.sprite 10, @game.height - 5, 'preloaderBg'
    @barbg.width = @game.width - 20
    @barbg.anchor.set 0, 1

    @barfg = @game.add.sprite 10, @game.height - 5, 'preloaderBar'
    @barfg.original_width = @barfg.width
    @barfg.width = @game.width - 20
    @barfg.anchor.set 0, 1
    @barfg_crop = new Phaser.Rectangle 0, 0, 0, @barfg.height
    @setProgress(Math.max(@level, 3))

    @populateEmitterChoices()

    # Start us off
    @numEmitters = 0
    @timeBetweenEmitters = 5
    @addEmitter()

  difficultyForLevel: (number) ->
    return 10 if number == 1
    return @difficultyForLevel(number-1) + 5 * number

  init: (@level) ->
    @difficulty = @difficultyForLevel @level

  setProgress: (amount) ->
    @progress = amount
    @barfg_crop.width = @barfg.original_width * (@progress / @difficulty)
    @barfg.crop(@barfg_crop)

    if @progress < 0
      @game.state.start 'gameover'
    if @progress >= @difficulty
      @game.state.start 'levels', true, false, @level+1

  populateEmitterChoices: ->
    left = ([-2, y] for y in [0...BOARD_HEIGHT])
    right = ([BOARD_WIDTH + 1, y] for y in [0...BOARD_HEIGHT])
    top = ([x, -2] for x in [0...BOARD_WIDTH])
    bottom = ([x, BOARD_HEIGHT + 1] for x in [0...BOARD_WIDTH])
    @choices = [
      { dx:  1, dy:  0, choices: left},
      { dx: -1, dy:  0, choices: right},
      { dx:  0, dy:  1, choices: top},
      { dx:  0, dy: -1, choices: bottom},
    ]

  update: ->
    [x, y, influence] = @grid.cursorPos()
    @cursor.x = x
    @cursor.y = y

    if @game.input.activePointer.isDown and influence == 0
      @grid.placeTileAtCursor(@cursor.frame)

    @nextEmitter -= @game.time.physicsElapsed

    @addEmitter() if @nextEmitter <= 0

module.exports = GameState
