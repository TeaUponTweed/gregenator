import random
import chess
import curses
import locale; locale.setlocale(locale.LC_ALL, '')
import functools
import itertools as it
import multiprocessing
import sys
import gmpy2
import time

def eval_board(board, color, gameover_result=None):
    white_mask = board.occupied_co[chess.WHITE]
    black_mask = board.occupied_co[chess.BLACK]
    material = ((gmpy2.popcount((board.pawns   & white_mask)) - gmpy2.popcount((board.pawns   & black_mask)))*1 +
                (gmpy2.popcount((board.knights & white_mask)) - gmpy2.popcount((board.knights & black_mask)))*3 +
                (gmpy2.popcount((board.bishops & white_mask)) - gmpy2.popcount((board.bishops & black_mask)))*3 +
                (gmpy2.popcount((board.rooks   & white_mask)) - gmpy2.popcount((board.rooks   & black_mask)))*5 +
                (gmpy2.popcount((board.queens  & white_mask)) - gmpy2.popcount((board.queens  & black_mask)))*9 +
                (gmpy2.popcount((board.kings   & white_mask)) - gmpy2.popcount((board.kings   & black_mask)))*1000)
    material = material if color else -material
    if abs(material) >= 9 or (gmpy2.popcount(white_mask) + gmpy2.popcount(black_mask)) < 9:
        if board.is_checkmate() and board.turn != color:
            return 10000
        elif board.is_game_over():
            return -100
    return material

def branch_first(board, depth, eval_func):
    alpha = float('-inf')
    for move in sorted(board.legal_moves, key = lambda x: iscapture(board, x), reverse=True):
        board.push(move)
        val = alphabeta(board, depth-1, alpha, float('inf'), False, eval_func)
        board.pop()
        if val > alpha:
            alpha = val
            bestmoves = [move]
        elif val == alpha:
            bestmoves.append(move)
    return bestmoves

def computer_player(side, look_ahead):
    eval_func = functools.partial(eval_board, color=side)
    pool = multiprocessing.Pool(4)
    def comp_turn(board):
        starttime = time.time()
        bestmoves = list(board.legal_moves)
        results = [pool.apply_async(branch_first, (board, depth, eval_func)) for depth in [2, 4, 6, 8]]
        for res in results:
            try:
                bestmoves = res.get(timeout=max(starttime+30-time.time(), .1))
            except multiprocessing.TimeoutError:
                pass
        assert len(bestmoves) > 0
        random.shuffle(bestmoves)
        for criteria in [lambda x: board.is_castling(x),
                         lambda x: (x.from_square in xrange(16)) or (x.from_square in xrange(48, 64)),
                         lambda x: not (board.piece_at(x.from_square).piece_type == chess.KING),
                         lambda x: True]:
            filtered_bestmoves = filter(criteria, bestmoves)
            if filtered_bestmoves:
                board.push(filtered_bestmoves[0])
                return False

    return comp_turn

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
