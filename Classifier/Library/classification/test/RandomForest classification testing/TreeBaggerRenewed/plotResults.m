function plotResults(model, predict_label, base)

    cl_obs = vertcat(base.class_obs);
    cl_obs = abs(cl_obs);
    % Установка цвета для каждого класса
    colorList = generateColorList(3); %сторонний скрипт
    
    [N D] = size(model.cl_ind);
    %Отрисовка обучающей выборки
    trueClassIndex = zeros(N,1);
    trueClassIndex(model.cl_ind==1) = 1;
    trueClassIndex(model.cl_ind==2) = 2;
    trueClassIndex(model.cl_ind==3) = 3;
    colorTrueClass = colorList(trueClassIndex,:);
    % Результат классификации
    resultClassIndex = zeros(length(predict_label),1);
    resultClassIndex(predict_label==1) = 1;
    resultClassIndex(predict_label==2) = 2;
    resultClassIndex(predict_label==3) = 3;
    colorResultClass = colorList(resultClassIndex,:);

    % Уменьшение размерности пространства до двумерного
    distanceMatrix = pdist(model.cl_obs,'euclidean');
    newCoor = mdscale(distanceMatrix,2);

    % Отрисовка всей выборки
    x = newCoor(:,1);
    y = newCoor(:,2);
    patchSize = 30; %max(prob_values,[],2);
    colorTrueClassPlot = colorTrueClass;
    figure; scatter(x,y,patchSize,colorTrueClassPlot);
    title('Обучающая выборка');
    
    distanceMatrix = pdist(cl_obs,'euclidean');
    newCoor = mdscale(distanceMatrix,2);
    x = newCoor(:,1);
    y = newCoor(:,2);
    patchSize = 30; %max(prob_values,[],2);
    colorResultClassPlot = colorResultClass;
    figure; scatter(x,y,patchSize,colorResultClassPlot);
    title('Тестирующая выборка');
end