import serial
import matplotlib
matplotlib.use("TkAgg")
import matplotlib.pyplot as plt

PORT="/dev/ttyACM0"
BAUD=115200
L = (1 << 12) - 1

# show the initial plot
fig = plt.figure("Accelerometer")
ax = fig.add_subplot(projection="3d")
ax.set_xlim(-L, L)
ax.set_ylim(-L, L)
ax.set_zlim(-L, L)
ax.set_xlabel(f"X raw (0-{L})")
ax.set_ylabel(f"Y raw (0-{L})")
ax.set_zlabel(f"Z raw (0-{L})")
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
        ax_c, ay_c, az_c, _ = tuple(map(float, parts))

        if not all(0 <= c <= L for c in (ax_c, ay_c, az_c)):
            continue

        if arrow is not None:
            arrow.remove()

        arrow = ax.quiver(0, 0, 0, ax_c, ay_c, az_c, linewidth=3)
        mag = (ax_c**2 + ay_c**2 + az_c**2) ** 0.5
        ax.set_title(f"X = {ax_c:.0f}    Y = {ay_c:.0f}    Z = {az_c:.0f}    mag = {mag:.0f}")
        plt.pause(0.01)

