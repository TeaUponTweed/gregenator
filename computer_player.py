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
import copy

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

def negamaxalphabeta(board, depth, alpha, beta, board_eval):
        if depth == 0:
            return board_eval(board)

        for move in board.pseudo_legal_moves:
            board.push(move)
            score = -negamaxalphabeta(board, depth-1, -beta, -alpha, board_eval)
            board.pop()
            if score >= beta:
                return beta
            if score > alpha:
                alpha = score
        return alpha

def branch_first(board, depth, eval_func):
    alpha = float('-inf')
    beta = float('inf')
    for move in sorted(board.legal_moves, key = lambda x: iscapture(board, x), reverse=True):
        board.push(move)
        val = -negamaxalphabeta(board, depth-1, -beta, -alpha, eval_func)
        board.pop()
        if val > alpha:
            alpha = val
            bestmoves = [move]
        elif val == alpha:
            bestmoves.append(move)
    return bestmoves

class ComputerPlayer(object):
    def __init__(self, side, look_ahead=[2,4,6,8]):
        self.side = side
        self.look_ahead = look_ahead
        self.pool = multiprocessing.Pool(maxtasksperchild=1)

    def __call__(self, board):
        eval_func = functools.partial(eval_board, color=self.side)
        bestmoves = list(board.legal_moves)
        results = [self.pool.apply_async(branch_first, args=(copy.deepcopy(board), depth, eval_func)) for depth in self.look_ahead]
        starttime = time.time()
        for res in results:
            try:
                bestmoves = res.get(starttime+15-time.time())
            except multiprocessing.TimeoutError:
                continue
        self.pool.terminate()
        self.pool.join()

        assert len(bestmoves) > 0
        random.shuffle(bestmoves)
        for criteria in [lambda x: board.is_castling(x),
                         lambda x: (x.from_square in range(16)) or (x.from_square in range(48, 64)),
                         lambda x: not (board.piece_at(x.from_square).piece_type == chess.KING),
                         lambda x: True]:
            filtered_bestmoves = filter(criteria, bestmoves)
            try:
                move = next(filtered_bestmoves)
                board.push(move)
                return False
            except StopIteration:
                pass

def iscapture(board, move):
    return board.is_capture(move)

def alphabeta(board, depth, alpha, beta, maximizingPlayer, board_eval):
    if depth == 0:
        return eval_board(board, maximizingPlayer)

    if maximizingPlayer:
        v = float('-inf')
        for move in board.pseudo_legal_moves:
            board.push(move)
            v = max(v, alphabeta(board, depth - 1, alpha, beta, False, None))
            board.pop()
            alpha = max(alpha, v)
            if beta <= alpha:
                break
        return v
    else:
        v = float('inf')
        for move in board.pseudo_legal_moves:
            board.push(move)
            v = min(v, alphabeta(board, depth - 1, alpha, beta, True, None))
            board.pop()
            beta = min(beta, v)
            if beta <= alpha:
                break
        return v
