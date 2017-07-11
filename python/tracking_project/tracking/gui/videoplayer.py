from __future__ import print_function
import tkinter as tk
from tkinter import messagebox, filedialog
from tkinter import ttk
import numpy as np
import cv2
from PIL import Image
from PIL import ImageTk
import threading
import datetime
import imutils
import os
from imutils.video import FileVideoStream
import time

class VideoPlayerApp():
    def __init__(self, master, vs):
        self.root = master
		# set a callback to handle when the window is closed
        self.root.wm_title("VideoPlayer")
        self.root.wm_protocol("WM_DELETE_WINDOW", self.onClose)
        #self.master.minsize(width=1200, height=600)

        self.vs = vs

        # start a thread that constantly pools the video sensor for
		# the most recently read frame
        self.stopEvent = threading.Event()
        self.thread = threading.Thread(target=self.videoLoop, args=())
        self.thread.start()

    def onClose(self):
		# set the stop event, cleanup the camera, and allow the rest of
		# the quit process to continue
        print("[INFO] closing...")
        self.stopEvent.set()
        self.vs.stop()
        self.root.quit()

    def videoLoop(self):
        # DISCLAIMER:
        # I'm not a GUI developer, nor do I even pretend to be. This
        # try/except statement is a pretty ugly hack to get around
        # a RunTime error that Tkinter throws due to threading
        try:
            # keep looping over frames until we are instructed to stop
            while not self.stopEvent.is_set():
                # grab the frame from the video stream and resize it to
# have a maximum width of 300 pixels
                _, frame = self.vs.read()
                frame = cv2.flip(frame, 1)
                cv2image = cv2.cvtColor(frame, cv2.COLOR_BGR2RGBA)
                img = Image.fromarray(cv2image)
                imgtk = ImageTk.PhotoImage(image=img)
                """
                # if the panel is not None, we need to initialize it
                if self.panel is None:
                    self.panel = tk.Label(image=image)
                    self.panel.image = image
                    self.panel.pack(side="left", padx=10, pady=10)
                # otherwise, simply update the panel
                else:
                	self.panel.configure(image=image)
                	self.panel.image = image
                """

        except RuntimeError:
            print("[INFO] caught a RuntimeError")

if __name__ == "__main__":
    tk.Tk().withdraw()
    cap = cv2.VideoCapture(filedialog.askopenfilename())
    time.sleep(2.0)

    # start the app
    root = tk.Tk()
    app = VideoPlayerApp(root, cap)
    app.root.mainloop()
