import numpy as np
import h5py
import sys
import scipy.io as sio
sys.path.append('../python_functions')

from nmf_setup_pipeline import param_sweep_rss

if __name__ == "__main__":
    k = np.arange(1, 30)
    beta_exp = np.linspace(-1, -5, 21)
    beta_range = np.power(np.ones(21)*10, beta_exp)
    nNodes = 264
    nTW = 51

    # decreased beta_range
    beta_range = beta_range[3:11]
    beta_exp = beta_exp[3:11]

    # save beta and k ranges
    sio.savemat('beta_range', {'beta_range': beta_range})
    sio.savemat('beta_exponent', {'beta_exp': beta_exp})
    sio.savemat('k_range', {'k_range': k})

    directory = '../ts36_wavelets_highpass/'
    filename = directory + 'PNC_ts36_highpass_concatenated_regress.hdf5'

    # load configuration matrix
    hdf = h5py.File(filename, 'r')
    c = hdf['config_matrix']
    print(c.shape)

    # parameter sweep
    output = param_sweep_rss(c, k, beta_range)
    sio.savemat('parameter_sweep', {'parameter' : output})

