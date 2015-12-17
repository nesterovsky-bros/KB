-- Note: {path to output folder} - is a folder where preprocessor output files.

set ansi_warings off

bulk insert Data.PropertyType
  from '{path to output folder}\metadata.txt'
  with(batchsize = 100000, datafiletype = 'widechar');

bulk insert Data.Property
  from '{path to output folder}\data.txt'
  with(batchsize = 100000, datafiletype = 'widechar');
