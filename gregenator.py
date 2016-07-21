import random
import chess
import curses
import locale; locale.setlocale(locale.LC_ALL, '')
import functools
import itertools as it
import multiprocessing
import gregenator_vis

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

def computer_player(side, look_ahead):
    objective_func = functools.partial(eval_board, color=side)
    def comp_turn(board):
        alpha = float('-inf')
        beta = float('inf')
        for move in sorted(board.legal_moves, key = lambda x: iscapture(board, x), reverse=True):
            board.push(move)
            val = alphabeta(board, look_ahead-1, alpha, beta, False, objective_func)
            board.pop()
            if val > alpha:
                alpha = val
                bestmoves = [move]
            elif val == alpha:
                bestmoves.append(move)
            why.write('%s\n' % alpha)
            why.write('%s\n\n' % val)
        board.push(random.choice(bestmoves))
        return False
    return comp_turn

def quiecent(board, board_eval):
    # init_val = board_eval(board)
    # for move in board.pseudo_legal_moves:
    #     board.push(move)
    #     val = board_eval(board)
    #     board.pop()
    #     if abs(val-init_val) > 3:
    #         return False
    return True

def iscapture(board, move):
    return board.is_capture(move)

def alphabeta(board, depth, alpha, beta, maximizingPlayer, board_eval):
    if depth == 0  or board.is_game_over():
        return board_eval(board)

    if maximizingPlayer:
        v = float('-inf')
        for move in board.pseudo_legal_moves:
            board.push(move)
            v = max(v, alphabeta(board, depth - 1, alpha, beta, False, board_eval))
            board.pop()
            alpha = max(alpha, v)
            if beta <= alpha:
                break
        return v
    else:
        v = float('inf')
        for move in board.pseudo_legal_moves:
            board.push(move)
            v = min(v, alphabeta(board, depth - 1, alpha, beta, True, board_eval))
            board.pop()
            beta = min(beta, v)
            if beta <= alpha:
                break
        return v

if __name__ == '__main__':
    board = chess.Board()
    curses.wrapper(gregenator_vis.UI, board)
