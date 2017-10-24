function displayResults(model, filenames, predict_label, prob_values) 
    for i = 1:size(predict_label, 1)
        if predict_label(i, 1) == 1
            predictLabel(i, 1) = model.classes(1, :);
        elseif predict_label(i, 1) == 2
            predictLabel(i, 1) = model.classes(2, :);
        elseif predict_label(i, 1) == 3
            predictLabel(i, 1) = model.classes(3, :); 
        elseif predict_label(i, 1) == 4
            predictLabel(i, 1) = model.classes(4, :);
        else
            predictLabel(i, 1) = model.classes(5, :);
        end
    end
    probSize = size(prob_values);
    %Вывод в коммандное окно название файла, предсказанного класса и
    %вероятности отнесения к классу
    for i = 1:1:probSize(1)
        if prob_values(i,1) >= prob_values(i, 2) && prob_values(i,1) >= prob_values(i, 3)
            accuracy = prob_values(i,1)*100;
            disp(filenames(i));
            disp(predictLabel(i));
            disp(accuracy);
        elseif prob_values(i,2) >= prob_values(i, 1) && prob_values(i,2) >= prob_values(i, 3)
            accuracy = prob_values(i,2)*100;
            disp(filenames(i));
            disp(predictLabel(i));
            disp(accuracy);
        else
            accuracy = prob_values(i,3)*100;
            disp(filenames(i));
            disp(predictLabel(i));
            disp(accuracy);
        end
    end
end