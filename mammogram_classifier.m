addpath('images');

m = 0;
labels = zeros(1,322);
fid = fopen('masslabels.txt');
tline = fgets(fid);
filenames = cell(1,322);

prev = 0;
while ischar(tline)
  disp(tline)
 
  index = str2num(tline(4:6));

  if (index > prev)
    m = m + 1;
    filenames{m} = strcat(tline(1:6),'.pgm');
  end

  if (regexp(tline,' M '))
    labels(m) = 1;
  end

  prev = index;

  tline = fgets(fid);
end

m = 322;

fclose(fid);

n = 24; %number of features

s = 4; %split factor for the smaller sub-images

X = zeros(n,s*s*m);

for i = 1:m
  fullIm = imread(filename{i},'pgm'); 
  s = length(A)/4; %assuming it's a square image
  for r = 1:4
    for c = 1:4
      instance = (i-1)*s*s + (r-1)*s + c;

      A = fullIm((r-1)*s+1:r*s, (c-1)*s+1:c*s);
      [f1,f2,f3,f4] = dwt2(A, 'db5');
      X(1:4, instance) = [var(f1(:)), var(f2(:)), var(f3(:)), var(f4(:))];
    
      X(5, instance) = mean2(A); %this paper claims that there are problems with black pixels

      X(6, instance) = std2(A);

      X(7, instance) = 1-1/(1+std2(A)^2);

      X(8, instance) = entropy(A); %check this!

      X(9, instance) = skewness(A(:));

      X(10,instance) = kurtosis(A(:));

      Pk = histc(A(:), unique(A));
      Pk = Pk/sum(Pk);
      X(11,instance) = sum(Pk.^2);
    end
  end
end
