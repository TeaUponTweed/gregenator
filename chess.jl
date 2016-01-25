abstract Piece # apparently bad practice see enum in http://docs.julialang.org/en/release-0.4/manual/style-guide/

immutable Empty <: Piece
end

type Pawn <: Piece
  side::Int
  hasMoved::Bool
end

type Knight <: Piece
  side::Int
  hasMoved::Bool
end

type Bishop <: Piece
  side::Int
  hasMoved::Bool
end

type Rook <: Piece
  side::Int
  hasMoved::Bool
end

type Queen <: Piece
  side::Int
  hasMoved::Bool
end

type King <: Piece
  side::Int
  hasMoved::Bool
end

type Move #Describes a move as a function which operates on a board and its inverse
  makeMove
  unmakeMove
end

function normalMove(board_, x1, y1, x2, y2)
  movingPiece = board_[y1, x1]
  takenPiece = board_[y2, x2]
  hasMoved = board_[y1, x1]
  function f(board)
    movingPiece.hasMoved = true
    board[y2, x2] = movingPiece
    board[y1, x1] = Empty()
  end
  function invf(board)
    movingPiece.hasMoved = hasMoved
    board[y1, x1] = movingPiece
    board[y2, x2] = takenPiece
  end
  return Move(f, invf)
end

Pawn(x) = Pawn(x, false)
Knight(x) = Knight(x, false)
Bishop(x) = Bishop(x, false)
Rook(x) = Rook(x, false)
Queen(x) = Queen(x, false)
King(x) = King(x, false)

function isEmpty(piece::Piece)
  return piece == Empty()
end

isWhite(piece::Piece) = !isEmpty(piece) && piece.side == 1
isBlack(piece::Piece) = !isEmpty(piece) && piece.side == -1

function sameSide(piece1, piece2)
  if isEmpty(piece1) || isEmpty(piece2)
    return false
  else
    return piece1.side == piece2.side
  end
end

function indexToXY(index, N)
  return index%N, div(index, N)
end


function XYToIndex(x, y, N)
  return N*y + x
end

function movesInDir(board, x, y, dir)
  dx, dy = dir
  xx, yy = x + dx, y+dy
  while inBounds(xx, yy)
    if isEmpty(board[yy, xx])
      produce(xx, yy)
    elseif !sameSide(board[yy, xx], board[y, x])
      produce(xx, yy)
      break
    else
      break
    end
    xx += dx
    yy += dy
  end
end

function diagonalMoves(board, x, y)
  for dir in [(i, j) for i in -1:2:1, j in -1:2:1]
    movesInDir(board, x, y, dir)
  end
end

function cardinalMoves(board, x, y)
  for dir in [(1, 0) (-1, 0) (0, 1) (0, -1)]
    movesInDir(board, x, y, dir)
  end
end

function knightMoves(board, x, y)

end

function inBounds(x, y, N)
  return 1 <= x <= N && 1 <= y <= N
end

inBounds(x, y) = inBounds(x, y, 8)

function moves(piece::Knight, board, x, y)
  for couple in [[(i, j) (j, i)] for i in -2:4:2, j in -1:2:1]
    for move in couple
      dx, dy = move
      xx = x + dx
      yy = y + dy
      if inBounds(xx, yy) && !sameSide(piece, board[yy, xx])
        produce((xx, yy), normalMove(board, x, y, xx, yy))
      end
    end
  end
end

function moves(piece, board, x, y)
  return
end

function moves(piece::Bishop, board, x, y)
  for (xx, yy) in Task(()->diagonalMoves(board, x, y))
    produce((xx, yy), normalMove(board, x, y, xx, yy))
  end
end

function moves(piece::Rook, board, x, y)
  for (xx, yy) in  Task(()->cardinalMoves(board, x, y))
    produce((xx, yy), normalMove(board, x, y, xx, yy))
  end
end

function moves(piece::Queen, board, x, y)
  for (xx, yy) in Task(()->diagonalMoves(board, x, y))
    produce((xx, yy), normalMove(board, x, y, xx, yy))
  end
  for (xx, yy) in  Task(()->cardinalMoves(board, x, y))
    produce((xx, yy), normalMove(board, x, y, xx, yy))
  end
end

function moves(piece::King, board, x, y)
  for dir in [(i, j) for i in -1:1, j in -1:1]
    dx, dy = dir
    if dx == dy == 0
      continue
    end
    xx = x + dx
    yy = y + dy
    if inBounds(xx, yy) && !sameSide(piece, board[yy, xx])
      produce((xx, yy), normalMove(board, x, y, xx, yy))
    end
  end
  # if !piece.hasMoved
  #   startRow = side==1 ? 1 : 8
  #   if !board[startRow, 1].hasMoved && all(map((x)->isEmpty(x), board[startRow, 2:x-1]))
  #
  #   end
  # end
end

function moves(piece::Pawn, board, x, y)
  dy = piece.side
  @assert piece.side != 0
  if inBounds(x, y+dy) && isEmpty(board[y+dy, x])
    produce((x, y+dy), normalMove(board, x, y, x, y+dy))
    if inBounds(x, y + 2*dy) && isEmpty(board[y + 2*dy, x]) && !piece.hasMoved
      produce((x, y + 2*dy), normalMove(board, x, y, x, y + 2*dy))
    end
  end
  yy = y + dy
  for dx in -1:2:1
    if inBounds(x + dx, yy) && !sameSide(piece, board[yy, x+dx]) && !isEmpty(board[yy, x+dx])
      produce((x+dx, yy), normalMove(board, x, y, x+dx, yy))
    end
  end
end

function display(piece::Empty)
  return ' '
end

function display(piece::Pawn)
  return 'p'
end

function display(piece::Knight)
  return 'n'
end

function display(piece::Bishop)
  return 'b'
end

function display(piece::Rook)
  return 'r'
end

function display(piece::Queen)
  return 'Q'
end

function display(piece::King)
  return 'K'
end

function executeMove(board, x1, y1, x2, y2)

end

function makeBoard()
  ([
    Rook(1)     Knight(1)     Bishop(1)     King(1)     Queen(1)     Bishop(1)     Knight(1)     Rook(1);
    Pawn(1)     Pawn(1)       Pawn(1)       Pawn(1)     Pawn(1)      Pawn(1)       Pawn(1)       Pawn(1);
    Empty()     Empty()       Empty()       Empty()     Empty()      Empty()       Empty()       Empty();
    Empty()     Empty()       Empty()       Empty()     Empty()      Empty()       Empty()       Empty();
    Empty()     Empty()       Empty()       Empty()     Empty()      Empty()       Empty()       Empty();
    Empty()     Empty()       Empty()       Empty()     Empty()      Empty()       Empty()       Empty();
    Pawn(-1)    Pawn(-1)      Pawn(-1)      Pawn(-1)    Pawn(-1)     Pawn(-1)      Pawn(-1)      Pawn(-1);
    Rook(-1)    Knight(-1)    Bishop(-1)    King(-1)    Queen(-1)    Bishop(-1)    Knight(-1)    Rook(-1);
  ])
end

function getCursesDisplay()
  global stdscr = ccall( (:initscr, :libncurses), Ptr{Void}, ())

  ccall( (:cbreak, :libncurses), Int32, ())
  ccall( (:noecho, :libncurses), Int32, ())
  ccall( (:keypad, :libncurses), Int32, (Ptr{Void}, Bool), stdscr, true)
  ccall( (:start_color, :libncurses), Int32, ())
  # ccall((:resizeterm, :libncurses), Int32, (Int32, Int32), 8*2, 8*2)

  ccall((:init_pair, :libncurses), Int32, (Int16, Int16, Int16), 1, 0, 3)
  ccall((:init_pair, :libncurses), Int32, (Int16, Int16, Int16), 2, 0, 11)
  ccall((:init_pair, :libncurses), Int32, (Int16, Int16, Int16), 3, 15, 3)
  ccall((:init_pair, :libncurses), Int32, (Int16, Int16, Int16), 4, 15, 11)
  ccall((:init_pair, :libncurses), Int32, (Int16, Int16, Int16), 5, 15, 1)
  ccall((:init_pair, :libncurses), Int32, (Int16, Int16, Int16), 6, 0, 1)

  blackOnBlack = ccall((:COLOR_PAIR, :libncurses), Int32, (Int32, ), 1)
  blackOnWhite = ccall((:COLOR_PAIR, :libncurses), Int32, (Int32, ), 2)
  whiteOnBlack = ccall((:COLOR_PAIR, :libncurses), Int32, (Int32, ), 3)
  whiteOnWhite = ccall((:COLOR_PAIR, :libncurses), Int32, (Int32, ), 4)
  whiteOnRed = ccall((:COLOR_PAIR, :libncurses), Int32, (Int32, ), 5)
  blackOnRed = ccall((:COLOR_PAIR, :libncurses), Int32, (Int32, ), 6)

  oldMask = UInt32(0)
  global KEY_MOUSE = 409#unsafe_load(cglobal((:KEY_MOUSE, :libncurses), UInt8))
  BUTTON1_PRESSED = 2#unsafe_load(cglobal((:BUTTON1_PRESSED, :libncurses), UInt32))
  BUTTON2_PRESSED = 128#unsafe_load(cglobal((:BUTTON2_PRESSED, :libncurses), UInt32))

  ccall((:mousemask, :libncurses), Int32, (UInt32, Ptr{UInt32}),
         BUTTON1_PRESSED,
         Ref(oldMask))
  function drawSubsetWithColor(board, color_pair, criteria)
    ccall((:attron, :libncurses), Int32, (Int32,), color_pair)
    for row in 1:8
      for col in 1:8
        if criteria(board, row, col)
          ccall((:wmove, :libncurses), Int32, (Ptr{Void}, Int32, Int32,), stdscr, row-1, col*2-2)
          ccall((:waddch, :libncurses), Int32, (Ptr{Void}, UInt8,), stdscr, display(board[row, col]))
          ccall((:wmove, :libncurses), Int32, (Ptr{Void}, Int32, Int32,), stdscr, row-1, col*2+1-2)
          ccall((:waddch, :libncurses), Int32, (Ptr{Void}, UInt8,), stdscr, ' ')
        end
      end
    end
    ccall((:attroff, :libncurses), Int32, (Int32,), color_pair)
  end

  function drawChessBoard(board, highlight...)
    ccall((:clear, :libncurses), Int32, ())

    drawSubsetWithColor(board, blackOnBlack, (b, r, c) -> (r%2) != (c%2) && isBlack(b[r, c]) && !((c, r) in highlight))
    ccall((:refresh, :libncurses), Int32, ())

    drawSubsetWithColor(board, blackOnWhite, (b, r, c) -> (r%2) == (c%2) && isBlack(b[r, c]) && !((c, r) in highlight))
    ccall((:refresh, :libncurses), Int32, ())

    drawSubsetWithColor(board, whiteOnBlack, (b, r, c) -> (r%2) != (c%2) &&  isWhite(b[r, c]) && !((c, r) in highlight))
    ccall((:refresh, :libncurses), Int32, ())

    drawSubsetWithColor(board, whiteOnWhite, (b, r, c) -> (r%2) == (c%2) &&  isWhite(b[r, c]) && !((c, r) in highlight))
    ccall((:refresh, :libncurses), Int32, ())

    drawSubsetWithColor(board, whiteOnWhite, (b, r, c) -> (r%2) == (c%2) &&  isEmpty(b[r, c]) && !((c, r) in highlight))
    ccall((:refresh, :libncurses), Int32, ())

    drawSubsetWithColor(board, whiteOnBlack, (b, r, c) -> (r%2) != (c%2) &&  isEmpty(b[r, c]) && !((c, r) in highlight))
    ccall((:refresh, :libncurses), Int32, ())

    drawSubsetWithColor(board, whiteOnRed, (b, r, c) -> isWhite(b[r, c]) && ((c, r) in highlight))
    ccall((:refresh, :libncurses), Int32, ())

    drawSubsetWithColor(board, blackOnRed, (b, r, c) -> isBlack(b[r, c]) && ((c, r) in highlight))
    ccall((:refresh, :libncurses), Int32, ())

    drawSubsetWithColor(board, whiteOnRed, (b, r, c) -> isEmpty(b[r, c]) && ((c, r) in highlight))
    ccall((:refresh, :libncurses), Int32, ())

    ccall((:wmove, :libncurses), Int32, (Ptr{Void}, Int32, Int32,), stdscr, 20, 20)
    ccall((:refresh, :libncurses), Int32, ())
  end
  return drawChessBoard;
end

type MEVENT
  id::Int16
  x::Int32
  y::Int32
  z::Int32
  mmask_t::UInt32
end
grr = 1;
MEVENT() = MEVENT(0, 0, 0, 0, 0)
wakka = []
function humanTurn(board, side)
  mevent = MEVENT()
  validMoves = Dict{Tuple{Int, Int}, Move}()
  while true
    ch = ccall((:getch, :libncurses), Int32, ())
    if ch == KEY_MOUSE
      ccall((:getmouse, :libncurses), Int32, (Ptr{MEVENT}, ), Ref(mevent))
      if 0 <= mevent.x < 16 && 0 <= mevent.y < 8
        y = mevent.y + 1
        x = div(mevent.x, 2) + 1
        if haskey(validMoves, (x, y))
          validMoves[(x, y)].makeMove(board)
          validMoves = Dict{Tuple{Int, Int}, Move}()
          drawBoard(board)
        elseif !isEmpty(board[y, x]) && board[y, x].side == side
          validMoves = Dict{Tuple{Int, Int}, Move}(Task(()-> moves(board[y, x], board, x, y)))
          drawBoard(board, keys(validMoves)...)
        else
          validMoves = Dict{Tuple{Int, Int}, Move}()
          drawBoard(board)
        end
      else
        break
      end
    end
  end
end

game_over = false;
drawBoard = getCursesDisplay();
try
# while not game_over
  global board = makeBoard();
  drawBoard(board);
  humanTurn(board, 1);
# end
finally
    ccall( (:keypad, :libncurses), Int32, (Ptr{Void}, Bool), stdscr, false)
    ccall((:endwin, :libncurses), Int32, ())
end
