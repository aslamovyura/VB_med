function [result]=Classification_fun(config, path, mdl)
%Res_pred,Config - struct with configurations. Field 'baseroot' contains a path to
%train set. Argument 'path' - to data, that you need to classify. 'mdl' is
%optional, it contains a result struct, that contains a model -
%classificator, that was trained before, then function not train, only predict.


    disp('Classification')
    config.baseroot=path;
    % Load base list
    base = vbr_process_base(config);
    %base - массив размерности, равной общему количеству файлов, из структур из
    %2-х полей-строк: filename - полный путь к каждому файлу; class -
    %принадлежность к классу согласно названию папки, в к-рой файл лежит.

    % Calculate observations
    base = vbr_process_observations(base, config);
    %Результат - структура base с добавленными полями fs (частота дискретизации),
    %полями со значениями информативных функций, class_obs:
    %при выбранном флаге "все комбинации" - вектор из значений  информативных функций.

    SAMPLE=vertcat(base.class_obs);
    CL_RES = result.model.classify(SAMPLE); %Классифицируем.

    %Make list of files and predicted classes.
    names={'filename','class'}; %Fields, that we need in.
    cl_val=according_names(names,base); %Cell array with fields values according to each file.
    Res_pred=[cl_val{:} CL_RES];
    result.base=[result.base; base];

end