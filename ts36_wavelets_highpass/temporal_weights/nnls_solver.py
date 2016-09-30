from nimfa.models import *
from nimfa.utils import *
from nimfa.utils.linalg import *

def fcnnls(C, A):
	"""
    NNLS for dense matrices.
    
    Nonnegative least squares solver (NNLS) using normal equations and fast
    combinatorial strategy (van Benthem and Keenan, 2004).
    
    Given A and C this algorithm solves for the optimal K in a least squares
    sense, using that A = C*K in the problem
    ||A - C*K||, s.t. K>=0 for given A and C. 
    
    C is the n_obs x l_var coefficient matrix
    A is the n_obs x p_rhs matrix of observations
    K is the l_var x p_rhs solution matrix
    
    p_set is set of passive sets, one for each column. 
    f_set is set of column indices for solutions that have not yet converged. 
    h_set is set of column indices for currently infeasible solutions. 
    j_set is working set of column indices for currently optimal solutions. 
    """
	C = C.todense() if sp.isspmatrix(C) else C
	A = A.todense() if sp.isspmatrix(A) else A
	_, l_var = C.shape
	p_rhs = A.shape[1]
	W = np.mat(np.zeros((l_var, p_rhs)))
	iter = 0
	max_iter = 3 * l_var
	# precompute parts of pseudoinverse
	CtC = dot(C.T, C)
	CtA = dot(C.T, A)
	# obtain the initial feasible solution and corresponding passive set
	# K is not sparse
	K = cssls(CtC, CtA)
	p_set = K > 0
	K[np.logical_not(p_set)] = 0
	D = K.copy()
	f_set = np.array(find(np.logical_not(all(p_set, axis=0))))
	# active set algorithm for NNLS main loop
	while len(f_set) > 0:
		# solve for the passive variables
		K[:, f_set] = cssls(CtC, CtA[:, f_set], p_set[:, f_set])
		# find any infeasible solutions
		idx = find(any(K[:, f_set] < 0, axis=0))
		h_set = f_set[idx] if idx != [] else []
		# make infeasible solutions feasible (standard NNLS inner loop)
		if len(h_set) > 0:
			n_h_set = len(h_set)
			alpha = np.mat(np.zeros((l_var, n_h_set)))
			while len(h_set) > 0 and iter < max_iter:
				iter += 1
				alpha[:, :n_h_set] = np.Inf
				# find indices of negative variables in passive set
				idx_f = find(
					np.logical_and(p_set[:, h_set], K[:, h_set] < 0))
				i_f = [l % p_set.shape[0] for l in idx_f]
				j_f = [l // p_set.shape[0] for l in idx_f]
				if len(i_f) == 0:
					break
				if n_h_set == 1:
					h_n = h_set * np.ones((1, len(j_f)))
					l_1n = i_f
					l_2n = h_n.tolist()[0]
				else:
					l_1n = i_f
					l_2n = [h_set[e] for e in j_f]
				t_d = D[l_1n, l_2n] / (D[l_1n, l_2n] - K[l_1n, l_2n])
				for i in range(len(i_f)):
					alpha[i_f[i], j_f[i]] = t_d.flatten()[0, i]
				alpha_min, min_idx = argmin(alpha[:, :n_h_set], axis=0)
				min_idx = min_idx.tolist()[0]
				alpha[:, :n_h_set] = repmat(alpha_min, l_var, 1)
				D[:, h_set] = D[:, h_set] - multiply(
					alpha[:, :n_h_set], D[:, h_set] - K[:, h_set])
				D[min_idx, h_set] = 0
				p_set[min_idx, h_set] = 0
				K[:, h_set] = cssls(
					CtC, CtA[:, h_set], p_set[:, h_set])
				h_set = find(any(K < 0, axis=0))
				n_h_set = len(h_set)
        # make sure the solution has converged and check solution for
        # optimality
		W[:, f_set] = CtA[:, f_set] - dot(CtC, K[:, f_set])
		npw = multiply(np.logical_not(p_set[:, f_set]), W[:, f_set])
		j_set = find(all(npw <= 0, axis=0))
		f_j = f_set[j_set] if j_set != [] else []
		f_set = np.setdiff1d(np.asarray(f_set), np.asarray(f_j))
		# for non-optimal solutions, add the appropriate variable to Pset
		if len(f_set) > 0:
			_, mxidx = argmax(
			    multiply(np.logical_not(p_set[:, f_set]), W[:, f_set]), axis=0)
			mxidx = mxidx.tolist()[0]
			p_set[mxidx, f_set] = 1
			D[:, f_set] = K[:, f_set]
	return K

def cssls(CtC, CtA, p_set=None):
	"""
	Solver for dense matrices. 

	Solve the set of equations CtA = CtC * K for variables defined in set p_set
	using the fast combinatorial approach (van Benthem and Keenan, 2004).
	"""
	K = np.mat(np.zeros(CtA.shape))
	if p_set is None or p_set.size == 0 or all(p_set):
		# equivalent if CtC is square matrix
		K = np.linalg.lstsq(CtC, CtA)[0]
		# K = dot(np.linalg.pinv(CtC), CtA)
	else:
		l_var, p_rhs = p_set.shape
		coded_p_set = dot(
			np.mat(2 ** np.array(list(range(l_var - 1, -1, -1)))), p_set)
		sorted_p_set, sorted_idx_set = sort(coded_p_set)
		breaks = diff(np.mat(sorted_p_set))
		break_idx = [-1] + find(np.mat(breaks)) + [p_rhs]
		for k in range(len(break_idx) - 1):
			cols2solve = sorted_idx_set[
				break_idx[k] + 1: break_idx[k + 1] + 1]
			vars = p_set[:, sorted_idx_set[break_idx[k] + 1]]
			vars = [i for i in range(vars.shape[0]) if vars[i, 0]]
			if vars != [] and cols2solve != []:
				A = CtC[:, vars][vars, :]
				B = CtA[:, cols2solve][vars,:]
				sol = np.linalg.lstsq(A, B)[0]
				i = 0
				for c in cols2solve:
					j = 0
					for v in vars:
						K[v, c] = sol[j, i]
						j += 1
					i += 1
				# K[vars, cols2solve] = dot(np.linalg.pinv(CtC[vars, vars]),
				# CtA[vars, cols2solve])
	return K