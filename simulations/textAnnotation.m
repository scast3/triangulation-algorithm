function textAnnotation(str, chosenTags)
% Places a text label in top-left or top area near the chosen tags region

    minx = min(chosenTags(:,1));
    maxy = max(chosenTags(:,2));
    text(minx, maxy + 0.5, str, 'Color','m','FontWeight','bold');
end