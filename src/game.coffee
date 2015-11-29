
TILE_SIZE = 32
BOARD_WIDTH = 15
BOARD_HEIGHT = 15


class GameState extends Phaser.State
  create: ->

    # Set up the blank tilemap for the board
    @map = @game.add.tilemap()
    @map.addTilesetImage 'map', 'map', TILE_SIZE, TILE_SIZE

    @layer1 = @map.create 'level1',
      BOARD_WIDTH, BOARD_HEIGHT, TILE_SIZE, TILE_SIZE
    @layer1.resizeWorld()

    @layer1.fixedToCamera = false;
    @layer1.position.set @game.width / 2, @game.height / 2
    @layer1.anchor.set 0.5

    # Fill the tilemap up with blanks
    @map.putTile(0, x, y, @layer1) for x in [0..BOARD_WIDTH] \
      for y in [0..BOARD_HEIGHT]

module.exports = GameState
