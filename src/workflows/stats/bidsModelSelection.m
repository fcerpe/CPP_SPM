function matlabbatch = bidsModelSelection(opt)
  %
  % Brief workflow description
  %
  % USAGE::
  %
  %  bidsModelSelection(opt)
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % (C) Copyright 2022 CPP_SPM developers

  checks(opt);

  workflowName = 'macs model selection';

  [~, opt] = setUpWorkflow(opt, workflowName);

  opt.orderBatches.MACS_model_space = 1;
  opt.orderBatches.MACS_BMS_group_auto = 4;

  names = getMacsModelNames(opt);

  matlabbatch{1}.spm.tools.MACS.MA_model_space.names = names;
  matlabbatch{1}.spm.tools.MACS.MA_model_space.model_files = opt.toolbox.MACS.model.files;
  %   matlabbatch{1}.spm.tools.MACS.MA_model_space.dir = {output_dir};

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    for iModel = 1:size(names, 1)

      opt.model.file = opt.toolbox.MACS.model.files{iModel};
      inputs = getBidsModelInput(opt.model.file);
      opt.space = {inputs.space};

      ffxDir = getFFXdir(subLabel, opt);

      spmMatFile = spm_select('FPList', ffxDir, 'SPM.mat');

      if isempty(spmMatFile)
        msg = sprintf('no SPM.mat found in:\n%s\n\n', ffxDir);
        id = 'noSPMmat';
        errorHandling(mfilename(), id, msg, false);
      end

      matlabbatch{1}.spm.tools.MACS.MA_model_space.models{1, iSub}{1, iModel} = spmMatFile;

    end

  end

  matlabbatch{2}.spm.tools.MACS.MA_cvLME_auto.MS_mat(1) = returnDefineModelSpaceDependency(opt);
  matlabbatch{2}.spm.tools.MACS.MA_cvLME_auto.AnC = 0;

  matlabbatch{3}.spm.tools.MACS.MS_PPs_group_auto.MS_mat(1) = returnDefineModelSpaceDependency(opt);
  matlabbatch{3}.spm.tools.MACS.MS_PPs_group_auto.LME_map = 'cvLME';

  matlabbatch{4}.spm.tools.MACS.MS_BMS_group_auto.MS_mat(1) = returnDefineModelSpaceDependency(opt);
  matlabbatch{4}.spm.tools.MACS.MS_BMS_group_auto.LME_map = 'cvLME';
  matlabbatch{4}.spm.tools.MACS.MS_BMS_group_auto.inf_meth = 'RFX-VB';
  matlabbatch{4}.spm.tools.MACS.MS_BMS_group_auto.EPs = 0;

  matlabbatch{5}.spm.tools.MACS.MS_SMM_BMS.BMS_mat(1) = ...
    cfg_dep('MS: perform BMS (automatic): BMS results (BMS.mat file)', ...
            returnDependency(opt, 'MACS_BMS_group_auto'), ...
            substruct('.', 'BMS_mat'));
  matlabbatch{5}.spm.tools.MACS.MS_SMM_BMS.extent = 10;

  saveAndRunWorkflow(matlabbatch, workflowName, opt);

end

function checks(opt)

  status = checkToolbox('MACS', 'install', true, 'verbose', opt.verbosity > 0);
  if ~status
    id = 'macsToolboxMissing';
    errorHandling(mfilename(), id, '', false);
  end

  if isempty(opt.toolbox.MACS.model.files)
    msg = sprintf('no model list provided in opt.toolbox.MACS.model.files');
    id = 'noModelList';
    errorHandling(mfilename(), id, msg, false);
  end

  % check all models have same space and task inputs
  modelFiles = opt.toolbox.MACS.model.files;

  for iModel = 1:numel(modelFiles)
    inputs{iModel, 1} = getBidsModelInput(modelFiles{iModel});
  end

  space = cellfun(@(x) x.space, inputs, 'UniformOutput', false);
  if numel(unique(space)) > 1
    msg = sprintf('All models must have same space inputs.');
    id = 'differentModelSpace';
    errorHandling(mfilename(), id, msg, false);
  end

  task = cellfun(@(x) x.task, inputs, 'UniformOutput', false);
  if numel(unique(task)) > 1
    msg = sprintf('All models must have same task inputs.');
    id = 'differentModelTasks';
    errorHandling(mfilename(), id, msg, false);
  end

end

function dep = returnDefineModelSpaceDependency(opt)

  dep = cfg_dep('MA: define model space: model space (MS.mat file)', ...
                returnDependency(opt, 'MACS_model_space'), ...
                substruct('.', 'MS_mat'));

end

function names = getMacsModelNames(opt)

  modelFiles = opt.toolbox.MACS.model.files;

  for iModel = 1:numel(modelFiles)
    names{iModel, 1} = getModelName(modelFiles{iModel});
  end

end
