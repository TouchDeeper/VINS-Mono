from evo.tools import file_interface
import numpy as np
import matplotlib
import matplotlib.pyplot as plt

rmses = []
start_index = 7
end_index = 27
for i in range(start_index,end_index):
  zip_file = "../GYR_W/ape" + str(i) + ".zip"
  result = file_interface.load_res_file(zip_file)
  rmse = result.stats["rmse"]
  #print("rmse:",rmse)
  rmses.append(rmse)
x = range(start_index, end_index, 1)
fig = plt.figure()

plt.xlabel("iteration")
plt.ylabel("rmse")

plt.plot(x, rmses, color="r", linestyle="-", marker="*", linewidth=1.0, label='euroc_gyr_w')
plt.xticks(range(start_index, end_index, 1))
fig.legend()
plt.show()

