% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_specifyContrasts %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_specifyContrasts_subject_level_F_contrast()
  %
  % to test the generation of F contrasts when there are several runs
  %

  taskName = 'motion';

  model = bids.Model('init', true);

  model.Input.task = taskName;

  model.Nodes{1}.Model.X = {'motion', 'static'};
  model.Nodes{1}.Level = 'Run';
  model.Nodes{1}.GroupBy = {'run', 'subject'};
  model.Nodes{1} = rmfield(model.Nodes{1}, 'Contrasts');
  model.Nodes{1} = rmfield(model.Nodes{1}, 'DummyContrasts');

  model.Nodes{2}.Model.X = 1;
  model.Nodes{2}.Level = 'Subject';
  model.Nodes{2}.GroupBy = {'contrast', 'subject'};
  model.Nodes{2}.Contrasts = struct('Test', 'F', ...
                                    'Name', 'F_test_mot_static', ...
                                    'ConditionList', {{'motion', 'static'}}, ...
                                    'Weights', [1 1]);

  SPM.Sess(1).col = [1, 2, 3];
  % skip Sess 2 to make sure contrast naming is based on the Sess number
  SPM.Sess(3).col = [4, 5, 6];
  SPM.Sess(4).col = [7, 8, 9];
  SPM.xX.name = { ...
                 ' motion*bf(1)'
                 ' static*bf(1)'
                 ' rot_x'
                 ' motion*bf(1)'
                 ' static*bf(1)'
                 ' rot_x'
                 ' motion*bf(1)'
                 ' static*bf(1)'
                 ' rot_x'
                };

  SPM.xX.X = ones(1, numel(SPM.xX.name));

  % WHEN
  contrasts = specifyContrasts(SPM, model);

  % THEN
  expected.name =  'F_test_mot_static';

  expected.C = zeros(6, 9);
  expected.C(1, 1) = 1;
  expected.C(2, 4) = 1;
  expected.C(3, 7) = 1;
  expected.C(4, 2) = 1;
  expected.C(5, 5) = 1;
  expected.C(6, 8) = 1;

  expected.type = 'F';

  assertEqual(contrasts, expected);

end

function test_specifyContrasts_vismotion_F_contrast()
  %
  % Note requires an SPM.mat to run
  %

  % GIVEN
  subLabel = '01';

  opt = setOptions('vismotion', subLabel, 'pipelineType', 'stats');

  ffxDir = getFFXdir(subLabel, opt);
  spmMatFile = cellstr(fullfile(ffxDir, 'SPM.mat'));
  load(spmMatFile{1}, 'SPM');

  opt.model.file = spm_file(opt.model.file, 'basename', 'model-vismotionFtest_smdl');
  model = BidsModel('file', opt.model.file);

  % WHEN
  contrasts = specifyContrasts(SPM, model);

  % THEN
  expected(1).name = 'VisMot_gt_VisStat_1'; %#ok<*AGROW>
  expected(1).C = [1 -1 0 0 0 0 0 0 0];
  expected(1).type = 't';

  expected(2).name = 'F_test_mot_static_1'; %#ok<*AGROW>
  expected(2).C = [1 0 0 0 0 0 0 0 0
                   0 1 0 0 0 0 0 0 0];
  expected(2).type = 'F';

  assertEqual(contrasts, expected);

end

function test_specifyContrasts_run_level_dummy_contrast_from_X()
  %
  % to test the generation of contrasts when there are several runs
  %

  taskName = 'motion';

  model = bids.Model('init', true);
  model.Input.task = taskName;
  model.Nodes{1}.Model.X = {'motion', 'static'};
  model.Nodes{1}.DummyContrasts = struct('Test', 't');
  model.Nodes{1} = rmfield(model.Nodes{1}, 'Contrasts');
  model.Nodes{1}.GroupBy = {'run', 'subject'};
  model.Nodes = model.Nodes{1};

  SPM.Sess(1).col = [1, 2];
  % skip Sess 2 to make sure contrast naming is based on the Sess number
  SPM.Sess(3).col = [3, 4];
  SPM.Sess(4).col = [5, 6];
  SPM.xX.name = { ...
                 ' motion*bf(1)'
                 ' static*bf(1)'
                 ' motion*bf(1)'
                 ' static*bf(1)'
                 ' motion*bf(1)'
                 ' static*bf(1)'
                };

  SPM.xX.X = ones(1, numel(SPM.xX.name));

  % WHEN
  contrasts = specifyContrasts(SPM, model);

  % THEN
  names_contrast = { ...
                    'motion_1', [1 0 0 0 0 0]
                    'motion_3', [0 0 1 0 0 0]
                    'motion_4', [0 0 0 0 1 0]
                    'static_1', [0 1 0 0 0 0]
                    'static_3', [0 0 0 1 0 0]
                    'static_4', [0 0 0 0 0 1]
                   };

  assertEqual(numel(contrasts), size(names_contrast, 1));

  for i = 1:size(names_contrast, 1)
    expected(i).name = names_contrast{i, 1};
    expected(i).C = names_contrast{i, 2};
    expected(i).type = 't';
    assertEqual(contrasts(i), expected(i));
  end

end

function test_specifyContrasts_missing_condition_for_dummy_contrasts()

  taskName = 'motion';

  % GIVEN
  DummyContrasts{1} = 'foo';

  model = bids.Model('init', true);
  model.Input.task = taskName;
  model.Nodes{1}.DummyContrasts.Contrasts = DummyContrasts;
  model.Nodes{1}.DummyContrasts.Test = 't';
  model.Nodes = model.Nodes{1};

  model.Nodes = rmfield(model.Nodes, 'Contrasts');

  SPM.Sess(1).col = [1, 2];
  SPM.xX.name = { ...
                 ' motion*bf(1)'
                 ' static*bf(1)'
                };

  SPM.xX.X = ones(1, numel(SPM.xX.name));

  % WHEN
  assertWarning(@()specifyContrasts(SPM, model), ...
                'specifyContrasts:noContrast');

  assertExceptionThrown(@()specifyContrasts(SPM, model), ...
                        'specifyContrasts:noContrast');

end

function test_specifyContrasts_missing_condition()

  taskName = 'motion';

  % GIVEN
  Contrasts.Name = 'motion_gt_foo';
  Contrasts.ConditionList = {'motion', 'foo'};
  Contrasts.Weights = [1, -1];
  Contrasts.Test = 't';

  model = bids.Model('init', true);
  model.Input.task = taskName;
  model.Nodes{1, 1}.Contrasts = Contrasts;
  model.Nodes = model.Nodes{1};

  model.Nodes = rmfield(model.Nodes, 'DummyContrasts');

  SPM.Sess(1).col = [1, 2];
  SPM.xX.name = { ...
                 ' motion*bf(1)'
                 ' static*bf(1)'
                };

  SPM.xX.X = ones(1, numel(SPM.xX.name));

  % WHEN
  assertWarning(@()specifyContrasts(SPM, model), ...
                'specifyContrasts:noContrast');

  assertExceptionThrown(@()specifyContrasts(SPM, model), ...
                        'specifyContrasts:noContrast');

end

function test_specifyContrasts_subject_level()

  taskName = 'motion';

  % GIVEN
  DummyContrasts{1} = 'motion';
  DummyContrasts{2} = 'static';

  Contrasts.Name = 'motion_gt_static';
  Contrasts.ConditionList = {'motion', 'static'};
  Contrasts.Weights = [1, -1];
  Contrasts.Test = 't';

  model = bids.Model('init', true);
  model.Nodes{2, 1} = bids.Model.empty_node('subject');
  model.Input.task = taskName;
  model.Nodes{1, 1}.DummyContrasts.Contrasts = DummyContrasts;
  model.Nodes{1, 1}.Contrasts = Contrasts;
  model.Nodes{2, 1}.GroupBy = {'subject', 'contrast'};
  model.Nodes{2, 1}.DummyContrasts = struct('Test', 't');
  model.Nodes{2, 1} = rmfield(model.Nodes{2}, 'Contrasts');
  model.Nodes{2, 1}.Model.X = 1;

  SPM.Sess(1).col = [1, 2];
  % skip Sess 2 to make sure contrast naming is based on the Sess number
  SPM.Sess(3).col = [3, 4];
  SPM.Sess(4).col = [5, 6];
  SPM.xX.name = { ...
                 ' motion*bf(1)'
                 ' static*bf(1)'
                 ' motion*bf(1)'
                 ' static*bf(1)'
                 ' motion*bf(1)'
                 ' static*bf(1)'
                };

  SPM.xX.X = ones(1, numel(SPM.xX.name));

  % WHEN
  contrasts = specifyContrasts(SPM, model);

  % THEN
  names_contrast = { ...
                    'motion_1', [1 0 0 0 0 0]
                    'motion_3', [0 0 1 0 0 0]
                    'motion_4', [0 0 0 0 1 0]
                    'static_1', [0 1 0 0 0 0]
                    'static_3', [0 0 0 1 0 0]
                    'static_4', [0 0 0 0 0 1]
                    'motion_gt_static_1', [1 -1 0 0 0 0]
                    'motion_gt_static_3', [0 0 1 -1 0 0]
                    'motion_gt_static_4', [0 0 0 0 1 -1]
                    'motion', [1 0 1 0 1 0]
                    'static', [0 1 0 1 0 1]
                    'motion_gt_static', [1 -1 1 -1 1 -1]
                   };

  assertEqual(numel(contrasts), size(names_contrast, 1));

  for i = 1:size(names_contrast, 1)
    expected(i).name = names_contrast{i, 1};
    expected(i).C = names_contrast{i, 2};
    expected(i).type = 't';
    assertEqual(contrasts(i), expected(i));
  end

end

function test_specifyContrasts_complex()
  %
  % to test the generation of contrasts when there are several runs
  %

  taskName = 'motion';

  % GIVEN
  DummyContrasts{1} = 'motion';
  DummyContrasts{2} = 'static';

  Contrasts.Name = 'motion_gt_static';
  Contrasts.ConditionList = {'motion', 'static'};
  Contrasts.Weights = [1, -1];
  Contrasts.Test = 't';

  model = bids.Model('init', true);
  model.Input.task = taskName;
  model.Nodes{1}.DummyContrasts.Contrasts = DummyContrasts;
  model.Nodes{1}.Contrasts = Contrasts;
  model.Nodes = model.Nodes{1};

  SPM.Sess(1).col = [1, 2];
  % skip Sess 2 to make sure contrast naming is based on the Sess number
  SPM.Sess(3).col = [3, 4];
  SPM.Sess(4).col = [5, 6];
  SPM.xX.name = { ...
                 ' motion*bf(1)'
                 ' static*bf(1)'
                 ' motion*bf(1)'
                 ' static*bf(1)'
                 ' motion*bf(1)'
                 ' static*bf(1)'
                };

  SPM.xX.X = ones(1, numel(SPM.xX.name));

  % WHEN
  contrasts = specifyContrasts(SPM, model);

  % THEN
  names_contrast = { ...
                    'motion_1', [1 0 0 0 0 0]
                    'motion_3', [0 0 1 0 0 0]
                    'motion_4', [0 0 0 0 1 0]
                    'static_1', [0 1 0 0 0 0]
                    'static_3', [0 0 0 1 0 0]
                    'static_4', [0 0 0 0 0 1]
                    'motion_gt_static_1', [1 -1 0 0 0 0]
                    'motion_gt_static_3', [0 0 1 -1 0 0]
                    'motion_gt_static_4', [0 0 0 0 1 -1]
                   };

  assertEqual(numel(contrasts), size(names_contrast, 1));

  for i = 1:size(names_contrast, 1)
    expected(i).name = names_contrast{i, 1};
    expected(i).C = names_contrast{i, 2};
    expected(i).type = 't';
    assertEqual(contrasts(i), expected(i));
  end

end

function test_specifyContrasts_vismotion()
  %
  % Note requires an SPM.mat to run
  %

  % GIVEN
  subLabel = '01';

  opt = setOptions('vismotion', subLabel, 'pipelineType', 'stats');

  ffxDir = getFFXdir(subLabel, opt);
  spmMatFile = cellstr(fullfile(ffxDir, 'SPM.mat'));
  load(spmMatFile{1}, 'SPM');

  model = BidsModel('file', opt.model.file);

  % WHEN
  contrasts = specifyContrasts(SPM, model);

  % THEN
  expected.name = 'VisMot_1'; %#ok<*AGROW>
  expected.C = [1 0 0 0 0 0 0 0 0];

  expected(end + 1).name = 'VisStat_1';
  expected(end).C = [0 1 0 0 0 0 0 0 0];

  expected(end + 1).name = 'VisMot_gt_VisStat_1';
  expected(end).C = [1 -1 0 0 0 0 0 0 0];

  expected(end + 1).name = 'VisStat_gt_VisMot_1';
  expected(end).C = [-1 1 0 0 0 0 0 0 0];

  expected(end + 1).name = 'VisMot';
  expected(end).C = [1 0 0 0 0 0 0 0 0];

  expected(end + 1).name = 'VisStat';
  expected(end).C = [0 1 0 0 0 0 0 0 0];

  expected(end + 1).name = 'VisMot_gt_VisStat';
  expected(end).C = [1 -1 0 0 0 0 0 0 0];

  expected(end + 1).name = 'VisStat_gt_VisMot';
  expected(end).C = [-1 1 0 0 0 0 0 0 0];

  assertEqual({contrasts.name}', {expected.name}');
  assertEqual({contrasts.C}', {expected.C}');

end

function test_specifyContrasts_vislocalizer()
  %
  % Note requires an SPM.mat to run
  %

  % GIVEN
  subLabel = '01';

  opt = setOptions('vislocalizer', subLabel, 'pipelineType', 'stats');
  opt.model.bm = BidsModel('file', opt.model.file);

  ffxDir = getFFXdir(subLabel, opt);
  spmMatFile = cellstr(fullfile(ffxDir, 'SPM.mat'));
  load(spmMatFile{1}, 'SPM');

  model = BidsModel('file', opt.model.file);

  % WHEN
  contrasts = specifyContrasts(SPM, model);

  % THEN
  expected.name = 'VisMot_1';
  expected.C = [1 0 0 0 0 0 0 0 0];

  expected(end + 1).name = 'VisStat_1';
  expected(end).C = [0 1 0 0 0 0 0 0 0];

  expected(end + 1).name = 'VisMot_&_VisStat_1';
  expected(end).C = [1 1 0 0 0 0 0 0 0];

  expected(end + 1).name =  'VisMot_&_VisStat_lt_baseline_1';
  expected(end).C = [-1 -1 0 0 0 0 0 0 0];

  expected(end + 1).name = 'VisMot';
  expected(end).C = [1 0 0 0 0 0 0 0 0];

  expected(end + 1).name = 'VisStat';
  expected(end).C = [0 1 0 0 0 0 0 0 0];

  expected(end + 1).name = 'VisMot_&_VisStat';
  expected(end).C = [1 1 0 0 0 0 0 0 0];

  expected(end + 1).name =  'VisMot_&_VisStat_lt_baseline';
  expected(end).C = [-1 -1 0 0 0 0 0 0 0];

  assertEqual({contrasts.name}', {expected.name}');
  assertEqual({contrasts.C}', {expected.C}');

end
