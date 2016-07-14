import random
import chess
import curses
import locale
import functools
import itertools as it
from collections import defaultdict
import multiprocessing

locale.setlocale(locale.LC_ALL, '')

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
    board.pop()

if __name__ == '__main__':
    pool = multiprocessing.Pool(8)

    board = chess.Board()
    p1 = computer_player(True, 4)
    p2 = computer_player(False, 2)

    while not board.is_game_over():
        current_player = p1 if board.turn else p2

        current_player(board)
        print board
        assert board.is_valid()
        print '-'*80
    print board
    print board.result()