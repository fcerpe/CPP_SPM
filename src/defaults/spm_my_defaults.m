function spm_my_defaults()
  %
  % USAGE::
  %
  %   spm_my_defaults()
  %
  % This is where we set the defaults we want to use.
  % These will overide the spm defaults.
  % When "not enough" information is specified in the batch files, SPM falls
  % back on the defaults to fill in the blanks.
  % This allows to make the scripts simpler.
  %

  % (C) Copyright 2019 bidspm developers

  global defaults

  % User Interface defaults
  % ==========================================================================
  defaults.ui.print   = 'png';

  % File format specific
  % ==========================================================================
  defaults.mat.format     = '-v7';

  % Realignment defaults
  % ==========================================================================
  defaults.realign.estimate.quality = 1;
  defaults.realign.estimate.interp  = 2;
  defaults.realign.estimate.wrap    = [0 0 0];
  defaults.realign.estimate.sep     = 2;
  defaults.realign.estimate.fwhm    = 5;
  defaults.realign.estimate.rtm     = 0;
  defaults.realign.write.mask       = 1;
  defaults.realign.write.interp     = 3;
  defaults.realign.write.wrap       = [0 0 0];
  defaults.realign.write.which      = [0 1];

  % Coregistration defaults
  % ==========================================================================
  defaults.coreg.estimate.cost_fun = 'nmi';
  defaults.coreg.estimate.sep      = [4 2];
  defaults.coreg.estimate.tol      = ...
      [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
  defaults.coreg.estimate.fwhm     = [7 7];

  % Spatial Normalisation defaults
  % ==========================================================================
  defaults.normalise.write.preserve   = 0;
  defaults.normalise.write.bb         = [[-78 -112 -70]; [78 76 85]];
  defaults.normalise.write.interp     = 4;

  % fMRI design defaults
  % ==========================================================================
  defaults.stats.fmri.t   = 16;
  defaults.stats.fmri.t0  = 8;
  defaults.stats.fmri.hpf = 128;
  defaults.stats.fmri.cvi = 'FAST';

  % Filename prefix defaults
  % ==========================================================================
  defaults.slicetiming.prefix           = 'a';
  defaults.realign.write.prefix         = 'r';
  defaults.coreg.write.prefix           = 'r';
  defaults.unwarp.write.prefix          = 'u';
  defaults.normalise.write.prefix       = 'w';
  defaults.deformations.modulate.prefix = 'm';
  defaults.smooth.prefix                = 's';
  defaults.imcalc.prefix                = 'i';

  % Set the defaults which are used by SPM
  % __________________________________________________________________________
  %
  % If you want to customise some defaults for your installation, do not
  % modify this file directly, but create a file named spm_my_defaults.m
  % instead, accessible from MATLAB search path; e.g., it can be saved in
  % MATLAB Startup Folder: userhome/Documents/MATLAB.
  %
  % Example: create the following file to change the image file extension:
  % ----------- file /home/karl/Documents/MATLAB/spm_my_defaults.m -----------
  % global defaults
  % defaults.images.format = 'img';
  % --------------------------------------------------------------------------
  %
  % spm_defaults should not be called directly in any script or function
  % (apart from SPM internals).
  % To load the defaults, use spm('Defaults',modality).
  % To get/set the defaults, use spm_get_defaults.

  % % User Interface defaults
  % %==========================================================================
  % defaults.ui.monitor = NaN;
  % defaults.ui.colour  = [0.58 0.77 0.57];
  % defaults.ui.fs      = 14;  % unused
  % defaults.ui.print   = 'ps';
  % defaults.renderer   = 'opengl';
  %
  % % File format specific
  % %==========================================================================
  % % Note that defaults.analyze.flip is no longer used.  Specifying the
  % % left/right handedness of the voxel indices is now done entirely by
  % % spm_flip_analyze_images.m
  % defaults.images.format  = 'nii'; % options: 'img', 'nii'
  % defaults.mat.format     = '-v6'; % options: '-mat', '-v6', '-v7.0', '-v7.3'
  %
  % % Toolboxes defaults
  % %==========================================================================
  % defaults.tbx.dir = { fullfile(spm('Dir'),'toolbox') };
  %
  % % DICOM Import defaults
  % %==========================================================================
  % defaults.dicom.root = 'flat'; % Folder hierarchy
  %
  % % fMRI design defaults
  % %==========================================================================
  % defaults.stats.fmri.t   = 16;
  % defaults.stats.fmri.t0  = 8;
  % defaults.stats.fmri.hpf = 128;
  % defaults.stats.fmri.cvi = 'AR(1)';
  % defaults.stats.fmri.hrf = [6 16 1 1 6 0 32];
  %
  % % Mask defaults
  % %==========================================================================
  % defaults.mask.thresh    = 0.8;
  %
  % % Stats defaults
  % %==========================================================================
  % defaults.stats.maxmem      = 2^29;
  % defaults.stats.maxres      = 64;
  % defaults.stats.resmem      = false;
  % defaults.stats.fmri.ufp    = 0.001;  % Upper tail F-probability
  % defaults.stats.pet.ufp     = 0.05;
  % defaults.stats.eeg.ufp     = 0.05;
  % defaults.stats.topoFDR     = 1;
  % defaults.stats.rft.nonstat = 0;
  % defaults.stats.results.volume.distmin =  8;
  % defaults.stats.results.volume.nbmax   =  3;
  % defaults.stats.results.svc.distmin    =  4;
  % defaults.stats.results.svc.nbmax      = 16;
  % defaults.stats.results.mipmat         = {fullfile(spm('dir'),'MIP.mat')};
  %
  % % Filename prefix defaults
  % %==========================================================================
  % defaults.slicetiming.prefix           = 'a';
  % defaults.realign.write.prefix         = 'r';
  % defaults.coreg.write.prefix           = 'r';
  % defaults.unwarp.write.prefix          = 'u';
  % defaults.normalise.write.prefix       = 'w';
  % defaults.deformations.modulate.prefix = 'm';
  % defaults.smooth.prefix                = 's';
  % defaults.imcalc.prefix                = 'i';
  %
  % % Realignment defaults
  % %==========================================================================
  % defaults.realign.estimate.quality = 0.9;
  % defaults.realign.estimate.interp  = 2;
  % defaults.realign.estimate.wrap    = [0 0 0];
  % defaults.realign.estimate.sep     = 4;
  % defaults.realign.estimate.fwhm    = 5;
  % defaults.realign.estimate.rtm     = 1;
  % defaults.realign.write.mask       = 1;
  % defaults.realign.write.interp     = 4;
  % defaults.realign.write.wrap       = [0 0 0];
  % defaults.realign.write.which      = [2 1];
  %
  % % Unwarp defaults
  % %==========================================================================
  % defaults.unwarp.estimate.rtm      = 0;
  % defaults.unwarp.estimate.fwhm     = 4;
  % defaults.unwarp.estimate.basfcn   = [12 12];
  % defaults.unwarp.estimate.regorder = 1;
  % defaults.unwarp.estimate.regwgt   = 1e5;
  % defaults.unwarp.estimate.foe      = [4 5];
  % defaults.unwarp.estimate.soe      = [];
  % defaults.unwarp.estimate.rem      = 1;
  % defaults.unwarp.estimate.jm       = 0;
  % defaults.unwarp.estimate.noi      = 5;
  % defaults.unwarp.estimate.expround = 'Average';
  % %
  % % Unwarp uses defaults.realign.write defaults for writing.
  % %
  %
  % % Coregistration defaults
  % %==========================================================================
  % defaults.coreg.estimate.cost_fun = 'nmi';
  % defaults.coreg.estimate.sep      = [4 2];
  % defaults.coreg.estimate.tol      = ...
  %  [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
  % defaults.coreg.estimate.fwhm     = [7 7];
  % defaults.coreg.write.interp      = 4;
  % defaults.coreg.write.wrap        = [0 0 0];
  % defaults.coreg.write.mask        = 0;
  %
  % % Spatial Normalisation defaults
  % %==========================================================================
  % defaults.normalise.write.preserve   = 0;
  % defaults.normalise.write.bb         = [[-78 -112 -70];[78 76 85]];
  % defaults.normalise.write.vox        = [2 2 2];
  % defaults.normalise.write.interp     = 4;
  %
  % % Old Spatial Normalisation defaults
  % %==========================================================================
  % defaults.old.normalise.estimate.smosrc  = 8;
  % defaults.old.normalise.estimate.smoref  = 0;
  % defaults.old.normalise.estimate.regtype = 'mni';
  % defaults.old.normalise.estimate.weight  = '';
  % defaults.old.normalise.estimate.cutoff  = 25;
  % defaults.old.normalise.estimate.nits    = 16;
  % defaults.old.normalise.estimate.reg     = 1;
  % defaults.old.normalise.write.preserve   = 0;
  % defaults.old.normalise.write.bb         = [[-78 -112 -70];[78 76 85]];
  % defaults.old.normalise.write.vox        = [2 2 2];
  % defaults.old.normalise.write.interp     = 1;
  % defaults.old.normalise.write.wrap       = [0 0 0];
  % defaults.old.normalise.write.prefix     = 'w';
  %
  % % VBM Preprocessing defaults
  % %==========================================================================
  % defaults.old.preproc.tpm     = cellstr(char(...
  %     fullfile(spm('Dir'),'toolbox','OldSeg','grey.nii'),...
  %     fullfile(spm('Dir'),'toolbox','OldSeg','white.nii'),...
  %     fullfile(spm('Dir'),'toolbox','OldSeg','csf.nii'))); % Prior probability maps
  % defaults.old.preproc.ngaus          = [2 2 2 4]'; % Gaussians per class
  % defaults.old.preproc.warpreg        = 1;          % Warping Regularisation
  % defaults.old.preproc.warpco         = 25;         % Warp Frequency Cutoff
  % defaults.old.preproc.biasreg        = 0.0001;     % Bias regularisation
  % defaults.old.preproc.biasfwhm       = 60;         % Bias FWHM
  % defaults.old.preproc.regtype        = 'mni';      % Affine Regularisation
  % defaults.old.preproc.fudge          = 5;          % Fudge factor, can not be set in batch GUI
  % defaults.old.preproc.samp           = 3;          % Sampling distance
  % defaults.old.preproc.output.GM      = [0 0 1];
  % defaults.old.preproc.output.WM      = [0 0 1];
  % defaults.old.preproc.output.CSF     = [0 0 0];
  % defaults.old.preproc.output.biascor = 1;
  % defaults.old.preproc.output.cleanup = 0;
  %
  % % Smooth defaults
  % %==========================================================================
  % defaults.smooth.fwhm = [8 8 8];
