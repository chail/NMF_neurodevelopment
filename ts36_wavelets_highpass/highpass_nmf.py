import sys
import numpy as np
sys.path.append("../python_functions/")
import scipy.io as sio
import nmf_setup_pipeline

nSubj = 200
nTW = 51
nNodes = 264
k = 10
beta = np.power(10, -2.0)

## normal pipeline

# get filenames
filenamelist = nmf_setup_pipeline.create_filename_list('./', '_rest_t020_o018.mat')

#create demeaned configuration matrix
nmf_setup_pipeline.demean_configuration_matrix(nSubj, nNodes, filenamelist)

#regress out motion
nmf_setup_pipeline.concatenate_motion_regression(nSubj, nTW, nNodes, filenamelist, 'PNC_ts36_highpass_concatenated_regress.hdf5')

#run nmf
nmf_setup_pipeline.run_nmf(nSubj, nNodes, k, beta,
                           'PNC_ts36_highpass_concatenated_regress.hdf5',
                           'PNC_ts36_highpass_NMF_output.hdf5')


# add demeaned configuration matrix for remaining 580 subjects
s = sio.loadmat('../subject_indices/idx_580')
subjects = s['idx_580']
filenamelist = []
directory = './'
filename_ext =  '_rest_t020_o018.mat'
for i in np.arange(len(subjects)):
	filename = directory + 'Aij_subj' + str(subjects[i][0]) + filename_ext
	print(filename)
	filenamelist.append(filename)

nmf_setup_pipeline.demean_configuration_matrix(nSubj, nNodes, filenamelist)

