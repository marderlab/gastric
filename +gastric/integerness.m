% small function to compute the integerness of remainders

function Y = integerness(X)

Y = 1 - 4*min(abs([X 1-X]),[],2);