import sys
import numpy as np
import scipy.io as sio
sys.path.append("../python_functions/")


import nmf_setup_pipeline

def window_count(filenamelist):
    num_windows = []
    for i in np.arange(len(filenamelist)):
        print(filenamelist[i])
        s = sio.loadmat(filenamelist[i])
        configuration_matrix = s['configuration_demean'].newbyteorder('=')
        num_windows.append(configuration_matrix.shape[1])
    sio.savemat('num_windows', {'num_windows': num_windows})
    return num_windows


if __name__ == "__main__":
    nSubj = 200
    nNodes = 263
    k = 10
    beta = np.power(10, -2.0)

    ## normal pipeline

    # get filenames
    filenamelist = nmf_setup_pipeline.create_filename_list('./', '_rest_t020_o018.mat')


    #create demeaned configuration matrix
    nmf_setup_pipeline.demean_configuration_matrix(nSubj, nNodes, filenamelist)

    # generate count of number of windows per subject
    num_windows = window_count(filenamelist)
    print(num_windows)

    #pipeline without motion regression, varied windows
    nmf_setup_pipeline.concatenate_varied_window_length(nSubj, sum(num_windows), nNodes, filenamelist, 'PNC_ts36_censor_concatenated_no_motion_regression.hdf5')
    nmf_setup_pipeline.run_nmf(nSubj, nNodes, k, beta, 'PNC_ts36_censor_concatenated_no_motion_regression.hdf5', 'PNC_ts36_censor_NMF_output_no_motion_regression.hdf5')
