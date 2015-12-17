-- Note: {path to output folder} - is a folder where preprocessor output files.

bulk insert Data.PropertyType
  from '{path to output folder}\metadata.txt'
  with(batchsize = 100000, datafiletype = 'widechar');

bulk insert Data.Property
  from '{path to output folder}\metadata.txt'
  with(batchsize = 100000, datafiletype = 'widechar');
