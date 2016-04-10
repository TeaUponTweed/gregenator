function sigm(a::Vector)
    1. ./ (1. + exp(-a))
end

function dsigm(a::Vector)
    s_a = sigm(a)
    s_a .* (1. - s_a)
end

function rect(a::Vector)
  max(a, 0)
end

function drect(a::Vector)
  return  ones(size(a))
end

function srect(a::Vector)
  log(1 + exp(a))
end

function dsrect(a::Vector)
  1./(1 + exp(-a))
end

function softmax(ann_output::Vector)
    ann_output = exp(ann_output)
    ann_output / sum(ann_output)
end

function get_activation_function(func::Symbol)
  if func == :sigm
    afunc = sigm
    dafunc = dsigm
  elseif func == :rect
    afunc = rect
    dafunc = drect
  elseif func == :srect
    afunc = srect
    dafunc = dsrect
  else
    throw("Unsupported activation function $func")
  end
  return afunc, dafunc
end

type NeuralNetworkLayer
  afunc::Function      # activation Function
  dafunc::Function     # derivative of activation function
  W::Matrix{Float64}   # weights
  x::Vector{Float64}   # input values
  pa::Vector{Float64}  # pre activation values
  H::Matrix{Float64}   # output gradient wrt W
end

function NeuralNetworkLayer(func::Symbol, nin::Int, nout::Int)
  afunc, dafunc = get_activation_function(func)
  NeuralNetworkLayer(afunc,
                     dafunc,
                     .1*randn(nout, nin),
                     zeros(nin),
                     zeros(nout),
                     zeros(nout, nin))
end

type NeuralNetwork
  layers::Vector{NeuralNetworkLayer} # layers
  P::Matrix{Float64} # uncertainty
  nparams::Int
end

function NeuralNetwork(layerspec)
  layers = Vector{NeuralNetworkLayer}()
  nparams = 0
  for (nin, nout, func) in layerspec
    nin += 1
    nparams += nin*nout
    push!(layers, NeuralNetworkLayer(func, nin, nout))
  end
  NeuralNetwork(layers, .1*eye(nparams), nparams)
end

function forward_propagate(nl, x::Vector)
    nl.x = x
    nl.pa = nl.W * x
    nl.afunc(nl.pa)
end

function backward_propagate(nl, grad::Vector)
  grad = grad.*nl.dafunc(nl.pa)
  nl.H = grad * nl.x'
  (nl.W[:, 1:end-1])' * grad
end

function predict(layers, x::Vector)
    for layer in layers
        x = forward_propagate(layer, [x..., 1])
    end
    x
end

function predict(layers, X::Matrix)
  n_obs, n_feats = size(X)
  for i = 1:n_obs
    x = X[i, :][:]
    input = x
    for layer in layers
        x = forward_propagate(layer, [x..., 1])
    end
    println("$input -> $x")
  end
end

function calc_derivitives(layers, grad::Vector)
  for layer in reverse(layers)
    grad = backward_propagate(layer, grad)
  end
end

function fit!(nn, x::Vector, y::Vector)
  y_pred = predict(nn.layers, x)
  grad = ones(size(y))
  calc_derivitives(nn.layers, grad)
  H = zeros(nn.nparams)
  n = 1
  for layer in nn.layers
    for h in layer.H
      H[n] = h
      n += 1
    end
  end
  R = eye(length(y)) * .001
  Q = eye(nn.nparams) * .001
  K = (nn.P*H)/(R + H'*nn.P*H)
  n = 1
  adj = K * (y-y_pred)
  for layer in nn.layers
    for i in eachindex(layer.W)
      layer.W[i] += adj[n]
      n += 1
    end
  end
  nn.P = nn.P - K*H'*nn.P + Q
end

function fit!(nn, X::Matrix, Y::Matrix)
  n_obs, n_feats = size(X)
  for i = 1:n_obs
    fit!(nn, X[i, :][:], Y[i, :][:])
  end
end

nTrain = 2000

X = rand(nTrain, 2) .< .5
Y = X[:, 1] .!= X[:, 2]
Y = convert(Matrix{Float64}, Y'')
X = convert(Matrix{Float64}, X)
nn = NeuralNetwork(((2, 4, :srect), (4, 1, :sigm)))
fit!(nn, X, Y)
predict(nn.layers, [[0 0]; [0 1]; [1 0]; [1 1]])
