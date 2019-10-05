from evo.tools import file_interface
import numpy as np
import matplotlib
import matplotlib.pyplot as plt

rmses = []
start_index = 10
end_index = 24
for i in range(start_index,end_index):
  zip_file = "../ACC_W/ape" + str(i) + ".zip"
  result = file_interface.load_res_file(zip_file)
  rmse = result.stats["rmse"]
  #print("rmse:",rmse)
  rmses.append(rmse)
x = range(start_index, end_index, 1)
fig = plt.figure()

plt.xlabel("iteration")
plt.ylabel("rmse")

plt.plot(x, rmses, color="r", linestyle="-", marker="*", linewidth=1.0, label='euroc_acc_w')
plt.xticks(range(start_index, end_index, 1))
fig.legend()
plt.show()

