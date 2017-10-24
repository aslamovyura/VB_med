function [result]=Classification_fun(config, path, mdl)
%Res_pred,Config - struct with configurations. Field 'baseroot' contains a path to
%train set. Argument 'path' - to data, that you need to classify. 'mdl' is
%optional, it contains a result struct, that contains a model -
%classificator, that was trained before, then function not train, only predict.


    disp('Classification')
    config.baseroot=path;
    % Load base list
    base = vbr_process_base(config);
    %base - ������ �����������, ������ ������ ���������� ������, �� �������� ��
    %2-� �����-�����: filename - ������ ���� � ������� �����; class -
    %�������������� � ������ �������� �������� �����, � �-��� ���� �����.

    % Calculate observations
    base = vbr_process_observations(base, config);
    %��������� - ��������� base � ������������ ������ fs (������� �������������),
    %������ �� ���������� ������������� �������, class_obs:
    %��� ��������� ����� "��� ����������" - ������ �� ��������  ������������� �������.

    SAMPLE=vertcat(base.class_obs);
    CL_RES = result.model.classify(SAMPLE); %��������������.

    %Make list of files and predicted classes.
    names={'filename','class'}; %Fields, that we need in.
    cl_val=according_names(names,base); %Cell array with fields values according to each file.
    Res_pred=[cl_val{:} CL_RES];
    result.base=[result.base; base];

end