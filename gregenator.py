import random
import chess
import curses
import locale
import functools
import itertools as it
from collections import defaultdict
import multiprocessing

locale.setlocale(locale.LC_ALL, '')

piece_vals = {
    0:0,
    1:1,
    2:3,
    3:3,
    4:5,
    5:9,
    6:1000
}

def piece_val(piece):
    return piece_vals[piece.piece_type]

# def naive_eval_board(board, color):
#     board_val = 0
#     for square in chess.SQUARES:
#         piece = board.piece_at(square)
#         if piece is not None:
#             # print piece, piece.color
#             if piece.color == color:
#                 board_val += piece_val(piece)
#             else:
#                 board_val -= piece_val(piece)
#     return board_val

# def naive_eval_board(board, color):
#     board_val = 0
#     if board.is_checkmate() and board.turn != color:
#         if color:
#             return 10000
#         else:
#             return -10000
#     elif board.is_game_over():
#         if color:
#             return -100
#         else:
#             return 100

#     for square in chess.SQUARES:
#         piece = board.piece_at(square)
#         if piece is not None:
#             # print piece, piece.color
#             if piece.color:
#                 board_val += piece_val(piece)
#             else:
#                 board_val -= piece_val(piece)
#     return board_val
def countbits(n):
  n = (n & 0x5555555555555555) + ((n & 0xAAAAAAAAAAAAAAAA) >> 1)
  n = (n & 0x3333333333333333) + ((n & 0xCCCCCCCCCCCCCCCC) >> 2)
  n = (n & 0x0F0F0F0F0F0F0F0F) + ((n & 0xF0F0F0F0F0F0F0F0) >> 4)
  n = (n & 0x00FF00FF00FF00FF) + ((n & 0xFF00FF00FF00FF00) >> 8)
  n = (n & 0x0000FFFF0000FFFF) + ((n & 0xFFFF0000FFFF0000) >> 16)
  n = (n & 0x00000000FFFFFFFF) + ((n & 0xFFFFFFFF00000000) >> 32)
  return n

def eval_board(board, color):
    white_mask = board.occupied_co[chess.WHITE]
    black_mask = board.occupied_co[chess.BLACK]
    material = ((countbits((board.pawns   & white_mask)) - countbits((board.pawns   & black_mask)))*1 +
                (countbits((board.knights & white_mask)) - countbits((board.knights & black_mask)))*3 +
                (countbits((board.bishops & white_mask)) - countbits((board.bishops & black_mask)))*3 +
                (countbits((board.rooks   & white_mask)) - countbits((board.rooks   & black_mask)))*5 +
                (countbits((board.queens  & white_mask)) - countbits((board.queens  & black_mask)))*9 +
                (countbits((board.kings   & white_mask)) - countbits((board.kings   & black_mask)))*1000)
    material = material if color else -material
    if abs(material) > 9 or (countbits(white_mask) + countbits(black_mask)) < 6:
        if board.is_checkmate() and board.turn != color:
            return 10000
        elif board.is_game_over():
            return -100
    return material
# def draw_board(stdscr, board):
#     stdscr.addstr(0, 0, board.__unicode__().encode("utf-8"))
#     # stdscr.addstr(str(board))
#     stdscr.refresh()
#     c = stdscr.getch()

def computer_player(side, look_ahead):
    objective_func = functools.partial(eval_board, color=side)
    # objective_func = naive_eval_board
    def comp_turn(board):
        # if few enough pieces
        # checkmate objective function
        # increase plys by 2
        # max_move = minmax_move(board, objective_func, look_ahead)
        allmoves = [pool.apply_async(wakka, (board, move, objective_func, look_ahead)) for move in board.legal_moves]
        allmoves = [r.get() for r in allmoves]
        bestmove_val, _ = max(allmoves)
        board.push(random.choice([move for val, move in allmoves if val == bestmove_val]))
    return comp_turn

def minmax(itr):
    maximum = float('-inf')
    minimum = float('inf')
    for el in itr:
        if el < minimum:
            minimum = el
        elif el > maximum:
            maximum = el
    return minimum, maximum

def gen_boards(board, halfmoves_ahead, initial_halfmoves):
    # print halfmoves_ahead, initial_halfmoves
    if (len(board.move_stack) == initial_halfmoves + halfmoves_ahead):# or board.is_game_over():
        yield board
    else:
        for move in board.pseudo_legal_moves:
            board.push(move)
            for b in gen_boards(board, halfmoves_ahead, initial_halfmoves):
                #check for valdiity?
                yield b
            board.pop()
# def alphabeta()
def quiecent(board):
    return True
def iscapture(move):
    return True
def alphabeta(board, depth, alpha, beta, maximizingPlayer, board_eval):
    if (depth <= 0 and quiecent(board)) or board.is_game_over():
        return board_eval(board)
    if maximizingPlayer:
        v = float('-inf')
        for move in sorted(board.pseudo_legal_moves, key = lambda x: iscapture(x), reverse=True):
            board.push(move)
            v = max(v, alphabeta(board, depth - 1, alpha, beta, False, board_eval))
            board.pop()
            alpha = max(alpha, v)
            if beta <= alpha:
                break
        return v
    else:
        v = float('inf')
        for move in sorted(board.pseudo_legal_moves, key = lambda x: board.is_capture(x), reverse=True):
            board.push(move)
            v = min(v, alphabeta(board, depth - 1, alpha, beta, True, board_eval))
            board.pop()
            beta = min(beta, v)
            if beta <= alpha:
                break
        return v

def wakka(board, first_move, func, halfmoves_ahead):
    board.push(first_move)
    return alphabeta(board, halfmoves_ahead-1, float('-inf'), float('inf'), False, func), first_move
    # alphabeta
# def wahtt(board, first_move, func, halfmoves_ahead):
#     initial_halfmoves = len(board.move_stack)
#     board.push(first_move)
#     # wakka = min(it.imap(func, gen_boards(board, halfmoves_ahead, initial_halfmoves)))
#     minimum, maximum = minmax(it.imap(func, gen_boards(board, halfmoves_ahead, initial_halfmoves)))
#     board.pop()
#     return minimum, first_move

def minmax_move(board, func, halfmoves_ahead): # TODO put max timeout in that bis
    # assert halfmoves_ahead & 1 == 0, 'Need even halfmoves ahead'
    # maxmoves = [pool.apply_async(wahtt, (board, move, func, halfmoves_ahead)) for move in board.legal_moves]
    maxmoves = [pool.apply_async(wakka, (board, move, func, halfmoves_ahead)) for move in board.legal_moves]
    maxmoves = [r.get() for r in maxmoves]
    # maxmoves = [wahtt(board, move, func, halfmoves_ahead) for move in board.legal_moves]
    # maxmove_val, _ = max(maxmoves)
    # maxmove_val, _ = max(maxmoves)
    # return random.choice([mm for mv, mm in maxmoves if mv == maxmove_val])
    # return max(

pool = multiprocessing.Pool(8)

board = chess.Board()
p1 = computer_player(True, 4)
p2 = computer_player(False, 2)
# current_player = p1
# for move in board.legal_moves:
#     board.push(move)
#     print board
#     print naive_eval_board(board, False)
#     print '-'*80
#     board.pop()

while not board.is_game_over():
    current_player = p1 if board.turn else p2

    print board.turn
    current_player(board)
    print board
    assert board.is_valid()
    # print board.turn
    print '-'*80
    # print board.__unicode__().encode("utf-8")
    # print boarda
    # assert board.is_valid()
print board
print board.result()
