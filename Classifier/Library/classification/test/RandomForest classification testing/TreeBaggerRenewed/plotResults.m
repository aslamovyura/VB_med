function plotResults(model, predict_label, base)

    cl_obs = vertcat(base.class_obs);
    cl_obs = abs(cl_obs);
    % ��������� ����� ��� ������� ������
    colorList = generateColorList(3); %��������� ������
    
    [N D] = size(model.cl_ind);
    %��������� ��������� �������
    trueClassIndex = zeros(N,1);
    trueClassIndex(model.cl_ind==1) = 1;
    trueClassIndex(model.cl_ind==2) = 2;
    trueClassIndex(model.cl_ind==3) = 3;
    colorTrueClass = colorList(trueClassIndex,:);
    % ��������� �������������
    resultClassIndex = zeros(length(predict_label),1);
    resultClassIndex(predict_label==1) = 1;
    resultClassIndex(predict_label==2) = 2;
    resultClassIndex(predict_label==3) = 3;
    colorResultClass = colorList(resultClassIndex,:);

    % ���������� ����������� ������������ �� ����������
    distanceMatrix = pdist(model.cl_obs,'euclidean');
    newCoor = mdscale(distanceMatrix,2);

    % ��������� ���� �������
    x = newCoor(:,1);
    y = newCoor(:,2);
    patchSize = 30; %max(prob_values,[],2);
    colorTrueClassPlot = colorTrueClass;
    figure; scatter(x,y,patchSize,colorTrueClassPlot);
    title('��������� �������');
    
    distanceMatrix = pdist(cl_obs,'euclidean');
    newCoor = mdscale(distanceMatrix,2);
    x = newCoor(:,1);
    y = newCoor(:,2);
    patchSize = 30; %max(prob_values,[],2);
    colorResultClassPlot = colorResultClass;
    figure; scatter(x,y,patchSize,colorResultClassPlot);
    title('����������� �������');
end