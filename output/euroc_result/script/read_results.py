from evo.tools import file_interface
for i in range(0,12):
  zip_file = "../ACC_N/ape" + str(i) + ".zip"
  result = file_interface.load_res_file(zip_file)
  rmse = result.stats["min"]
  print("min:",rmse)

print("hello world")
