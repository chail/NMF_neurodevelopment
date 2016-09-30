# NMF_neurodevelopment
analysis pipeline for non-negative matrix factorization on the Philadelphia Neurodevelopmental Cohort

- - - -

1. install libraries
  * install nimfa, scipy, and numpy for python: `pip install nimfa`

2. place PNC data in the pnc_data directory, data available through NIH dbGaP
  *	n780_censor.mat
  *	n780_despike.mat
  *	ts_36_ev.mat
  *	age.mat
  *	cognDataCollection.mat
  *	coordinatesXYZ.mat
  *	mvmt.mat
  *	neuralSystem.xlsx
  *	sex.mat

3. generate old and young subject groups in subject indicies directory
  *	we used the 100 oldest and 100 youngest subjects for our analyses

4. build association matrices using wavelet coherence
  *	wavelet toolbox used for generated wavelet coherence: <http://www.glaciology.net/wavelet*coherence>
  *	this toolbox is included in the matlab_functions directory
  * navigate to ts36_wavelets_highpass directory
  *	run wavelet_coherence.m file in matlab
  *	it may be useful to split this process into several batch processes
  *	repeat these stets in the ts36_wavelets_censor directory

5. parameter grid search
  * in the parameter_sweep directory run `python parameter_sweep.py`
  *	this saves the result in a .mat file in that directory
  *	the grid search will take a few days to complete running

6. pre-nmf processing and running nmf
  *	in the ts36_wavelets_highpass directory run `python highpass_nmf.py`
  *	this will concatenate the subject matrices and regress out motion, then run nmf
  *	you can also run `python highpass_nmf_supplement.py` in the same directory for additional processing pipelines
  * in the ts36_wavelets_censor directory run `python censer_nmf.py`

7. in nmf_master.py running each pipeline will generate figures

8. code to generate figures are located in the figures directory. BrainNetViewer was used to visualize the nodes 

