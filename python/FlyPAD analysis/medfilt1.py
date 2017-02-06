import numpy as np

def medfilt1(x, n=2, blksize=0, dim=0):
    """
    MEDFILT1 One dimensional median filter translated from MATLAB
    ================
    Input parameters:
    x:          input signal (numpy ndarray)
    n:          determining window size (default: 3) --> median of x( k-(n-1)/2 : k+(n-1)/2+1 ) for n odd; x( k-N/2 : k + N/2 ) for n events
    blksize:    blocksize (default: 0)
    dim:        operates along dimension dim (default: 0)
    """

    assert dim <= x.ndim, \
    "Error: given dimension %d is larger than the input array dimension %d" \
    % (dim, x.ndim)                                                             # assert that given dimension is smaller equal than the dimension of the input array

    #% Reshape x into the right dimension.
    #if isempty(DIM)
    #	% Work along the first non-singleton dimension
    #	[x, nshifts] = shiftdim(x);
    #else
    #	% Put DIM in the first (row) dimension (this matches the order
    #	% that the built-in filter function uses)
    #	perm = [DIM,1:DIM-1,DIM+1:ndims(x)];
    #	x = permute(x,perm);
    #end

    # Verify that the block size is valid.
    sz = x.shape;
    if blksize = 0:
    	blksize = sz[0]                                                         # sz[0] is the number of rows of x (default)

    # Initialize output with the correct dimension
    output = np.zeros(sz)                                                       # output array with same shape as input array containing zeros

    # Call medfilt1D (vector)
    for i  in range(sz[1:].prod()):
    	y[:,i] = medfilt1D(x(:,i),n,blksz);

    # Convert y to the original shape of x
    if isempty(DIM):
    	y = shiftdim(y, -nshifts);
    else:
    	y = ipermute(y,perm);


### LOCAL FUNC
def medfilt1D_vec(x, n=2, blksize=0):
    """
    MEDFILT1D_VEC  One dimensional median filter.

    Inputs:
    x     - vector
    n     - order of the filter
    blksz - block size
    """
    nx = length(x);
    if rem(n,2)~=1    % n even
        m = n/2;
    else
        m = (n-1)/2;
    end
    X = [zeros(m,1); x; zeros(m,1)];
    y = zeros(nx,1);

    % Work in chunks to save memory
    indr = (0:n-1)';
    indc = 1:nx;
    for i=1:blksz:nx
        ind = indc(ones(1,n),i:min(i+blksz-1,nx)) + ...
              indr(:,ones(1,min(i+blksz-1,nx)-i+1));
        xx = reshape(X(ind),n,min(i+blksz-1,nx)-i+1);
        y(i:min(i+blksz-1,nx)) = median(xx,1);
    end
    return output

if __name__ = "__main__":
    a = np.zeros(6)
    medfilt1(a, 2, 0, 1)
