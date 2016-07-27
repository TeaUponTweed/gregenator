import chess
import random
import computer_player
import functools

def negamax(board, depth, color):
        if depth == 0:
            return color * computer_player.eval_board(board)

        max_score = float('-inf')

        for move in board.pseudo_legal_moves:
            board.push(move)
            score = -negamax(board, depth - 1, -color)
            board.pop()
            if score > max_score:
                max_score = score
        return max_score

if __name__ == '__main__':
    board = chess.Board()
    while not board.is_game_over():
        for depth in [1, 2, 3]:
            color =  1 if board.turn else -1
            ab =  computer_player.negamaxalphabeta(board, depth, float('-inf'), float('inf'), color)
            assert (negamax(board, depth, color) == ab)
            print(ab)
            print(-computer_player.negamaxalphabeta(board, depth, float('inf'), float('-inf'), -color))
            print('#'*8)
        board.push(random.choice(list(board.legal_moves)))
        print(board)
