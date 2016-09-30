import numpy as np
import scipy.io as sio
import h5py
import nimfa



def create_filename_list(directory, filename_ext, filename_young =
                         '../subject_indices/idx_young', filename_old =
                         '../subject_indices/idx_old'):
	y = sio.loadmat(filename_young)
	young = y['young']

	o = sio.loadmat(filename_old)
	old = o['old']

	subjects = np.concatenate((young, old), axis = 0)

	filenamelist = []
	for i in np.arange(len(subjects)):
		filename = directory + 'Aij_subj' + str(subjects[i][0]) + filename_ext
		print(filename)
		filenamelist.append(filename)

	return filenamelist

def demean_configuration_matrix(nSubj, nNodes, filenamelist):

	for i in np.arange(len(filenamelist)):
		print(i)
		filename = filenamelist[i]
		f = sio.loadmat(filename)
		Aij = f['Aij']
		nTW = len(Aij)
		configuration_demean = np.zeros((nNodes*(nNodes-1)/2, nTW))
		for j in np.arange(nTW):
			m = Aij[j][0] #get square matrix of wavelets
			triu1 = np.triu_indices(nNodes, 1) #upper triangular values
			avg = np.mean(m[triu1])
			configuration_demean[:, j] = m[triu1] / avg

		f['configuration_demean'] = configuration_demean
		sio.savemat(filename, f)
	return

def concatenate_motion_regression(nSubj, nTW, nNodes, filenamelist,
                                  output_filename, truncate = 'middle',
                                  filename_young =
                                  '../subject_indices/idx_young', filename_old =
                                  '../subject_indices/idx_old'):
    y = sio.loadmat(filename_young)
    young = y['young']

    o = sio.loadmat(filename_old)
    old = o['old']

    nEdges = (nNodes * nNodes - nNodes) / 2
    nCol = nTW* nSubj

    #output file
    h5f = h5py.File(output_filename, 'w')
    h5f.create_dataset('config_matrix', (nEdges, nCol), dtype = 'f8')

    #load config matrix into h5py file
    for i in np.arange(len(filenamelist)):
        print(i)
        s = sio.loadmat(filenamelist[i])
        configuration_matrix = s['configuration_demean'].newbyteorder('=')

        ## if windows need to be truncated
        if (configuration_matrix.shape[1] > nTW):
            # truncate from beginning and end, keeping middle
            if (truncate == 'middle'):
                overflow = configuration_matrix.shape[1] - nTW
                start = round(overflow / 2)
                stop = start + nTW
                h5f['config_matrix'][:,nTW*i:nTW*(i+1)] = configuration_matrix[:, start:stop]
            # truncate from end
            elif(truncate == 'end'):
                h5f['config_matirx'][:,nTW*i:nTW*(i+1)] = configuration_matrix[:, :nTW]
        else:
            h5f['config_matrix'][:,nTW*i:nTW*(i+1)] = configuration_matrix


    # subtract 1 from indices since subject numbers range from 1-780 and mvmt
    # indices range from 0-779
    subject_idx= np.concatenate((young, old), axis = 0) - 1
    m = sio.loadmat('../pnc_data/mvmt.mat')
    m = m['mvmt']

    #corresponding mvt for all 200 subjects
    mvt = np.squeeze(m[subject_idx])


    (nRows, nCols) = h5f['config_matrix'].shape

    for i in np.arange(nRows):
        v = h5f['config_matrix'][i,:]
        print(i)
        for j in np.arange(nTW):
            idx = np.arange(0, nTW * nSubj, nTW) + j
            aij = v[idx]
            p = np.polyfit(mvt, aij, 1)
            aij_new = aij - mvt*p[0]
            aij_new[aij_new < 0] = 0 #set negative entries to zero
            h5f['config_matrix'][i, idx] = aij_new

    h5f.close()
    return

def concatenate(nSubj, nTW, nNodes, filenamelist, output_filename, truncate =
                "middle", filename_young = '../subject_indices/idx_young',
                filename_old = '../subject_indices/idx_old') :
	y = sio.loadmat(filename_young)
	young = y['young']

	o = sio.loadmat(filename_old)
	old = o['old']

	nEdges = (nNodes * nNodes - nNodes) / 2
	nCol = nTW* nSubj

	#output file
	h5f = h5py.File(output_filename, 'w')
	h5f.create_dataset('config_matrix', (nEdges, nCol), dtype = 'f8')

	#load config matrix into h5py file
	for i in np.arange(len(filenamelist)):
		print(i)
		s = sio.loadmat(filenamelist[i])
		configuration_matrix = s['configuration_demean'].newbyteorder('=')
		# if window length needs to be truncated
		if (configuration_matrix.shape[1] > nTW):
			# truncate from beginning and end, keeping middle
			if (truncate == 'middle'):
				overflow = configuration_matrix.shape[1] - nTW
				start = round(overflow / 2)
				stop = start + nTW
				h5f['config_matrix'][:,nTW*i:nTW*(i+1)] = configuration_matrix[:, start:stop]
			# truncate from end
			elif (truncate == 'end'):
				h5f['config_matrix'][:,nTW*i:nTW*(i+1)] = configuration_matrix[:, :nTW]
		else:
			h5f['config_matrix'][:,nTW*i:nTW*(i+1)] = configuration_matrix

	h5f.close()
	return

def concatenate_varied_window_length(nSubj, total_windows, nNodes,
                                     filenamelist, output_filename,
                                     filename_young =
                                     '../subject_indices/idx_young',
                                     filename_old =
                                     '../subject_indices/idx_old'):
	y = sio.loadmat(filename_young)
	young = y['young']

	o = sio.loadmat(filename_old)
	old = o['old']

	nEdges = (nNodes * nNodes - nNodes) / 2
	nCol = total_windows

	#output file
	h5f = h5py.File(output_filename, 'w')
	h5f.create_dataset('config_matrix', (nEdges, nCol), dtype = 'f8')

	#load config matrix into h5py file
	start = 0;
	for i in np.arange(len(filenamelist)):
		print(i)
		s = sio.loadmat(filenamelist[i])
		configuration_matrix = s['configuration_demean'].newbyteorder('=')
		nTW = configuration_matrix.shape[1]
		h5f['config_matrix'][:,start:start+nTW] = configuration_matrix
		start = start + nTW

	h5f.close()
	return


def run_nmf(nSubj, nNodes, k, beta, input_filename, output_filename):


    triuIdx = np.triu_indices(nNodes, k=1)

    filename = input_filename
    save_file = output_filename
    print(filename)
    h5f = h5py.File(filename, 'r')
    c = h5f['config_matrix']
    print(c.shape)

    eta = np.max(c)**2

#	fctr = nimfa.mf(c, seed = 'nndsvd', rank = k, \
#	method = 'snmf', max_iter = 30, initialize_only = True, \
#	version = 'r', eta = eta, beta = beta, i_conv = 10, w_min_change = 0)
#	fctr_res = nimfa.mf_run(fctr)

    snmf = nimfa.Snmf(c, seed="nndsvd", rank=k, max_iter=30, version='r', eta=eta, \
    beta=beta, i_conv=10, w_min_change=0)
    fctr_res = snmf()

    #output matrices
    basis = np.array(fctr_res.basis())
    expr = np.array(fctr_res.coef()).T

    #reshape subnetworks
    coactMatr = np.zeros((k, nNodes, nNodes))
    for c in np.arange(k):
        basisNet = np.zeros((nNodes, nNodes))
        basisNet[triuIdx[0], triuIdx[1]] = basis[:, c]
        basisNet += basisNet.T
        coactMatr[c,...] = basisNet[...]

    #save output
    f = h5py.File(save_file, 'w')
    f.create_dataset('subnetworks', data = coactMatr)
    f.create_dataset('timeseries', data = expr)

    h5f.close()
    f.close()

#does a parameter sweep over specified values for beta and k
#V = configuration matrix
#k_range = range of values for k
#beta_range = range of values for beta
#returns struct containing rss over the parameter space and min value
def param_sweep_rss(V, k_range, beta_range):
    k_length = k_range.size
    beta_length = beta_range.size
    nEdges = V.shape[0] #num rows
    nBlocks= V.shape[1] #num cols

    parameter_space = np.zeros((k_length, beta_length))
    eta = np.max(V)**2

    for ii in np.arange(k_length):
        for jj in np.arange(beta_length):
            print(jj)
            k = k_range[ii]
            beta = beta_range[jj]

			#fctr = nimfa.mf(V, seed = 'nndsvd', rank=k, \
			#	method='snmf', max_iter=30, initialize_only=True, \
			#	version='r', eta = eta, beta = beta, i_conv = 10, w_min_change = 0)
			#fctr_res = nimfa.mf_run(fctr)

            snmf = nimfa.Snmf(c, seed="nndsvd", rank=k, max_iter=30, version =
                              'r', eta=eta, beta=beta, i_conv=10, w_min_change=0)
            fctr_res = snmf()
            parameter_space[ii, jj] = fctr_res.fit.rss()
        print(ii)

	return {'parameter_space': parameter_space}


