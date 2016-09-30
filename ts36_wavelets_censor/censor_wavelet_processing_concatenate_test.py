import numpy as np
import scipy.io as sio
import h5py

directory = '/Users/chail/MATLAB/PNC states project/ts36_wavelets_censor/'
concatenate_filename = 'PNC_ts36_censor_concatenated_no_motion_regression.hdf5'

y = sio.loadmat('../idx_young')
young = y['young']

o = sio.loadmat('../idx_old')
old = o['old']

n = sio.loadmat('num_windows.mat')
num_windows = n['num_windows'][0]


subjects = np.concatenate((young, old), axis = 0)

directory = '/Users/chail/MATLAB/PNC states project/ts36_wavelets_censor/'
filenamelist = []

for i in np.arange(len(subjects)):
	filename = directory + 'Aij_subj' + str(subjects[i][0]) + '_rest_t020_o018.mat'
	print(filename)
	filenamelist.append(filename)


h5f = h5py.File(concatenate_filename, 'r')
configuration_matrix = h5f['config_matrix']


start = 0
for i in np.arange(len(filenamelist)):
	print(i)
	subject_data = sio.loadmat(filenamelist[i])
	c = subject_data['configuration_demean'].newbyteorder('=')
	end = start + num_windows[i]
	print(end)
	result = np.array_equal(configuration_matrix[:, start:end], c)
	start = start+num_windows[i]
	print(result)

	if (result != True):
		print('mismatch')
		break

h5f.close()