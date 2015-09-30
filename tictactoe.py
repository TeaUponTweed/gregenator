from collections import defaultdict
import numpy as np

class Board:
  def __init__(self, size):
    self.size = size
    self.state = [0] * size**2
  
  def is_terminal(self):
    for ax in self.get_axes():
      print ax
      if len(ax) == 1 and ax[0] != 0:
        return False
    return True

  def get_axes(self):
    for start in xrange(self.size):
      yield [self.state[i] for i in xrange(start, self.size**2, self.size)]
      yield [self.state[i] for i in xrange(start*self.size, start*self.size+self.size, 1)]
    yield [self.state[i] for i in xrange(0, self.size**2, self.size+1)]
    yield [self.state[i] for i in xrange(self.size-1, self.size**2-1, self.size-1)]

    # for i in xrange
    # for row in self.state:
      # yield row
    # for col in self.state.T:
      # yield col
    # yield np.diag(self.state)
    # yield [self.state[i][self.size-i-1] for i in xrange(self.size) ]
    # yield np.diag(np.fliplr(self.state))

  def reward():
    pass

  def next_states(self, side):
    for i in xrange(self.size):
      for j in xrange(self.size):
        if self.state[i, j] == 0:
          next_state = list(self.state.flatten())
          next_state[i][j] = side
          yield tuple(next_state)

  def __repr__(self):
    return self.state.__repr__()

class naiiveTD:
  def __init__(self):
    self.V = defaultdict(int)

class RL:
  def __init__(self, env, evaluator):
    self.env = env
    self.evaluator = evaluator

if __name__ == '__main__':
  b = Board(3)
  b.state = range(9)
  print np.array(b.state).reshape((3, 3))
  for ax in b.get_axes():
    print ax
  # for st in  b.next_states(2):
    # print st
  # b.state = np.array(xrange(9)).reshape((3,3))
  # print b.state
  # print '####'
  # b.is_terminal()
