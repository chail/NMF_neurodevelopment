import sys
import numpy as np
sys.path.append("../python_functions/")

import nmf_setup_pipeline


if __name__ == '__main__':
    nSubj = 200
    nTW = 51
    nNodes = 264
    k = 10
    beta = np.power(10, -2.0)


    ## no motion regression step

    # get filenames
    filenamelist = nmf_setup_pipeline.create_filename_list('./', '_rest_t020_o018.mat')

    #no motion regression
    nmf_setup_pipeline.concatenate(nSubj, nTW, nNodes, filenamelist, 'PNC_ts36_highpass_concatenated_no_motion_regression.hdf5')

    #run nmf
    nmf_setup_pipeline.run_nmf(nSubj, nNodes, k, beta, 'PNC_ts36_highpass_concatenated_no_motion_regression.hdf5', 'PNC_ts36_highpass_NMF_output_no_motion_regression.hdf5')

    # run nmf using next youngest/oldest 200 subjects
    # get filenames
    filename_young = '../subject_indices/idx_young_next_100'
    filename_old = '../subject_indices/idx_old_next_100'
    filenamelist = nmf_setup_pipeline.create_filename_list('./',
                                                           '_rest_t020_o018.mat',
                                                          filename_young =
                                                           filename_young,
                                                          filename_old =
                                                           filename_old)
    #regress out motion
    nmf_setup_pipeline.concatenate_motion_regression(nSubj, nTW, nNodes,
                                                     filenamelist,
                                                     'PNC_ts36_highpass_concatenated_regress_next_100.hdf5',
                                                    filename_young =
                                                     filename_young,
                                                     filename_old =
                                                     filename_old)
    nmf_setup_pipeline.run_nmf(nSubj, nNodes, k, beta,
                               'PNC_ts36_highpass_concatenated_regress_next_100.hdf5',
                               'PNC_ts36_highpass_NMF_output_next_100.hdf5')

    ## robustness to beta - using beta = 0
    nmf_setup_pipeline.run_nmf(nSubj, nNodes, k, 0, 'PNC_ts36_highpass_concatenated_regress.hdf5', 'PNC_ts36_highpass_NMF_output_zero_beta.hdf5')

    ## using 8 subgraphs k = 8
    nmf_setup_pipeline.run_nmf(nSubj, nNodes, 8, beta, 'PNC_ts36_highpass_concatenated_regress.hdf5', 'PNC_ts36_highpass_NMF_output_k8.hdf5')

    ## using 12 subgraphs k = 12
    nmf_setup_pipeline.run_nmf(nSubj, nNodes, 12, beta, 'PNC_ts36_highpass_concatenated_regress.hdf5', 'PNC_ts36_highpass_NMF_output_k12.hdf5')

    ## using 6 subgraphs k = 6
    nmf_setup_pipeline.run_nmf(nSubj, nNodes, 6, beta, 'PNC_ts36_highpass_concatenated_regress.hdf5', 'PNC_ts36_highpass_NMF_output_k6.hdf5')

    ## using 45 subgraphs k = 45
    nmf_setup_pipeline.run_nmf(nSubj, nNodes, 45, beta, 'PNC_ts36_highpass_concatenated_regress.hdf5', 'PNC_ts36_highpass_NMF_output_k45.hdf5')
