import serial
import matplotlib

matplotlib.use("TkAgg")
import matplotlib.pyplot as plt

PORT = "/dev/ttyACM0"
BAUD = 115200
L = 2

# show the initial plot
fig = plt.figure("Accelerometer")
ax = fig.add_subplot(projection="3d")
ax.set_xlim(-L, L)
ax.set_ylim(-L, L)
ax.set_zlim(-L, L)
ax.set_xlabel(f"X (g)")
ax.set_ylabel(f"Y (g)")
ax.set_zlabel(f"Z (g)")
ax.scatter(0, 0, 0, c="k", s=40)

# draw axes through origin to make (0,0,0) obvious
ax.plot([-L, L], [0, 0], [0, 0], color="0.6")
ax.plot([0, 0], [-L, L], [0, 0], color="0.6")
ax.plot([0, 0], [0, 0], [-L, L], color="0.6")
ax.set_box_aspect([1, 1, 1])
arrow = None

# enable the interactive plot
plt.ion()
plt.show()

with serial.Serial(PORT, BAUD) as ser:
    while plt.fignum_exists(fig.number):
        # discard the backlog one line at a time, so that the
        # newest reading is the one plotted
        while ser.in_waiting > 200:
            ser.readline()

        # ---- STEP 1: split the line and convert the first three
        #              fields into ax_c, ay_c, and az_c
        line = ser.readline().decode(errors="ignore").strip()
        parts = line.split(",")
        if len(parts) != 4:
            continue
        ax_g, ay_g, az_g, flag = tuple(map(float, parts))
        flag = flag == 1

        if any(abs(v) > 8 for v in (ax_g, ay_g, az_g)):
            continue

        if arrow is not None:
            arrow.remove()

        arrow = ax.quiver(0, 0, 0, ax_g, ay_g, az_g, linewidth=3)
        mag = (ax_g**2 + ay_g**2 + az_g**2) ** 0.5

        if not flag:
            ax.set_title(f"(X, Y, Z) = ({ax_g:.3f}, {ay_g:.3f}, {az_g:.3f})    |a| = {mag:.2f}", color="k")
        else:
            ax.set_title(f"|a| = {mag:.2f}    FALL DETECTED", color="r")

        plt.pause(0.01)
