import h5py
import scipy.io as sio
import numpy as np
import nnls_solver

"""
uses nnls_solver.py to back-compute temporal weights matrix H given basis
matrix W for each of 780 PNC subjects
"""


# open subnetworks matrix
f = h5py.File('../PNC_ts36_highpass_NMF_output.hdf5', 'r')
subnetworks = f['subnetworks']
nSubnetworks = subnetworks.shape[0]
nNodes = subnetworks.shape[1]

nRows = nNodes * (nNodes - 1) / 2
nCols = nSubnetworks

w = np.zeros((nRows, nCols))

# unfold subgraphs to W basis matrix
for i in np.arange(nSubnetworks):
	idx = np.triu_indices(nNodes, 1)
	s = subnetworks[i,:,:]
	w[:, i] = s[idx]

k = 10
beta = np.power(10, -2.0)
#eta = np.max(A)**2
nNodes = 264

for subj in np.arange(1, 781):
	filename = '../Aij_subj' + str(subj) + '_rest_t020_o018.mat'
	# open file
	f2 = sio.loadmat(filename)
	A = f2['configuration_demean']
	nTW = A.shape[1]

	# concatenate sparsity parameter
	beta_vec = np.sqrt(beta) * np.ones((1, k))
	a1 = np.zeros((1, A.shape[1]))

	# optimize temporal weights given subgraphs
	h = nnls_solver.fcnnls(np.vstack((w, beta_vec)) , np.vstack((A, a1)))
	h = np.array(h)

	#save output
	save_filename = 'nnls_temporal_weight_subj' + str(subj) + '.mat'
	sio.savemat(save_filename, {'h':h})

f.close()






