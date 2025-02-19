#
# Copyright (c) 2024 STMicroelectronics
# All rights reserved.
#
# This software is licensed under terms that can be found in the LICENSE file
# in the root directory of this software component.
# If no LICENSE file comes with this software, it is provided AS-IS.

import gi
import time

ENABLE_CAMERA = False  # Replace with actual condition
ENABLE_DISPLAY = False  # Replace with actual condition

if ENABLE_DISPLAY:
    gi.require_version('Gtk', '3.0')
    from gi.repository import Gtk, Gdk, GdkPixbuf, GLib
    Gtk.init(None)
    Gtk.init_check(None)

if ENABLE_CAMERA:
    gi.require_version('Gst', '1.0')
    from gi.repository import Gst
    Gst.init(None)
    Gst.init_check(None)

import numpy as np
import argparse
import signal
import os
import random
import json
import subprocess
import re
import os.path
#added - start
from datetime import datetime
import cv2
#added - stop
from os import path
from PIL import Image
from timeit import default_timer as timer
from mobilenet_pp import NeuralNetwork

import requests
from PIL import Image
import numpy as np

# Set constants for S3 bucket and object names
S3_BUCKET_NAME = "aiimagecapture"
BOTTOM_IMAGE_URL = f"https://{S3_BUCKET_NAME}.s3.amazonaws.com/bottom.jpg"
LOG_FILE_URL = f"https://{S3_BUCKET_NAME}.s3.amazonaws.com/classification_log.txt"
classification_file_path = '/usr/iotc/local/data/classification'

CONFIG_PATH = '/usr/iotc/local/config.json'

# Argument parsing
parser = argparse.ArgumentParser(description="S3 Image Classification")
parser.add_argument("-m", "--model_file", required=True, help="Path to the model file")
parser.add_argument("-l", "--label_file", required=True, help="Path to the label file")
parser.add_argument("--framerate", type=int, default=30, help="Framerate for the camera")
parser.add_argument("--frame_width", type=int, default=760, help="Width of the camera frame")
parser.add_argument("--frame_height", type=int, default=568, help="Height of the camera frame")
parser.add_argument("--dual_camera_pipeline", action='store_true', help="Use dual camera pipeline if available")
parser.add_argument("--input_mean", type=float, default=127.5, help="Input mean for the neural network")
parser.add_argument("--input_std", type=float, default=127.5, help="Input standard deviation for the neural network")
parser.add_argument("--validation", action='store_true', help="Enable validation mode")
parser.add_argument("--val_run", default=50, help="Number of runs for validation")
parser.add_argument('--image', type=str, default=None, help='Path to the image file')
args = parser.parse_args()

# Debugging: print the parsed arguments
print("Model file:", args.model_file)
print("Label file:", args.label_file)
print("Framerate:", args.framerate)
print("Frame width:", args.frame_width)
print("Frame height:", args.frame_height)
print("Dual camera pipeline:", args.dual_camera_pipeline)
print("Image:", args.image)
print("Validation:", args.validation)
#added - stop

#path definition
RESOURCES_DIRECTORY = os.path.abspath(os.path.dirname(__file__)) + "/../resources/"

if ENABLE_CAMERA:
    class GstWidget(Gtk.Box):
        """
        Class that handles Gstreamer pipeline using gtkwaylandsink and appsink
        """
        def __init__(self, app, nn):
            super().__init__()
            # connect the gtkwidget with the realize callback
            self.connect('realize', self._on_realize)
            self.instant_fps = 0
            self.app = app
            self.nn = nn
            self.cpt_frame = 0
            self.isp_first_config = True
        def _on_realize(self, widget):
            if(args.dual_camera_pipeline):
                self.camera_pipeline_preview_creation()
                self.nn_pipeline_creation()
                self.pipeline_preview.set_state(Gst.State.PLAYING)
                self.pipeline_nn.set_state(Gst.State.PLAYING)
            else :
                self.camera_pipeline_creation()

        def camera_pipeline_creation(self):
            if not ENABLE_CAMERA:
                print("Camera pipeline creation skipped.")
                return True
        # Continue with the rest of the pipeline creation code if ENABLE_CAMERA is True
            """
            creation of the gstreamer pipeline when gstwidget is created dedicated to handle
            camera stream and NN inference (mode single pipeline)
            """
            # gstreamer pipeline creation
            self.pipeline_preview = Gst.Pipeline()

            # creation of the source v4l2src
            self.v4lsrc1 = Gst.ElementFactory.make("v4l2src", "source")
            video_device = "/dev/" + str(self.app.video_device_prev)
            self.v4lsrc1.set_property("device", video_device)

            #creation of the v4l2src caps
            caps = str(self.app.camera_caps_prev) + ", framerate=" + str(args.framerate)+ "/1"
            print("Camera pipeline configuration : ",caps)
            camera1caps = Gst.Caps.from_string(caps)
            self.camerafilter1 = Gst.ElementFactory.make("capsfilter", "filter1")
            self.camerafilter1.set_property("caps", camera1caps)

            # creation of the videoconvert elements
            self.videoformatconverter1 = Gst.ElementFactory.make("videoconvert", "video_convert1")
            self.videoformatconverter2 = Gst.ElementFactory.make("videoconvert", "video_convert2")

            self.tee = Gst.ElementFactory.make("tee", "tee")

            # creation and configuration of the queue elements
            self.queue1 = Gst.ElementFactory.make("queue", "queue-1")
            self.queue2 = Gst.ElementFactory.make("queue", "queue-2")
            self.queue1.set_property("max-size-buffers", 1)
            self.queue1.set_property("leaky", 2)
            self.queue2.set_property("max-size-buffers", 1)
            self.queue2.set_property("leaky", 2)

            # creation and configuration of the appsink element
            self.appsink = Gst.ElementFactory.make("appsink", "appsink")
            nn_caps = "video/x-raw, format = RGB, width=" + str(self.app.nn_input_width) + ",height=" + str(self.app.nn_input_height)
            nncaps = Gst.Caps.from_string(nn_caps)
            self.appsink.set_property("caps", nncaps)
            self.appsink.set_property("emit-signals", True)
            self.appsink.set_property("sync", False)
            self.appsink.set_property("max-buffers", 1)
            self.appsink.set_property("drop", True)
            self.appsink.connect("new-sample", self.new_sample)

            # creation of the gtkwaylandsink element to handle the gestreamer video stream
            self.gtkwaylandsink = Gst.ElementFactory.make("gtkwaylandsink")
            self.pack_start(self.gtkwaylandsink.props.widget, True, True, 0)
            self.gtkwaylandsink.props.widget.show()

            # creation and configuration of the fpsdisplaysink element to measure display fps
            self.fps_disp_sink = Gst.ElementFactory.make("fpsdisplaysink", "fpsmeasure1")
            self.fps_disp_sink.set_property("signal-fps-measurements", True)
            self.fps_disp_sink.set_property("fps-update-interval", 2000)
            self.fps_disp_sink.set_property("text-overlay", False)
            self.fps_disp_sink.set_property("video-sink", self.gtkwaylandsink)
            self.fps_disp_sink.connect("fps-measurements",self.get_fps_display)

            # creation of the video rate and video scale elements
            self.video_rate = Gst.ElementFactory.make("videorate", "video-rate")
            self.video_scale = Gst.ElementFactory.make("videoscale", "video-scale")

            # Add all elements to the pipeline
            self.pipeline_preview.add(self.v4lsrc1)
            self.pipeline_preview.add(self.camerafilter1)
            self.pipeline_preview.add(self.videoformatconverter1)
            self.pipeline_preview.add(self.videoformatconverter2)
            self.pipeline_preview.add(self.tee)
            self.pipeline_preview.add(self.queue1)
            self.pipeline_preview.add(self.queue2)
            self.pipeline_preview.add(self.appsink)
            self.pipeline_preview.add(self.fps_disp_sink)
            self.pipeline_preview.add(self.video_rate)
            self.pipeline_preview.add(self.video_scale)

            # linking elements together
            #                              -> queue 1 -> videoconvert -> fpsdisplaysink
            # v4l2src -> video rate -> tee
            #                              -> queue 2 -> videoconvert -> video scale -> appsink
            self.v4lsrc1.link(self.video_rate)
            self.video_rate.link(self.camerafilter1)
            self.camerafilter1.link(self.tee)
            self.queue1.link(self.videoformatconverter1)
            self.videoformatconverter1.link(self.fps_disp_sink)
            self.queue2.link(self.videoformatconverter2)
            self.videoformatconverter2.link(self.video_scale)
            self.video_scale.link(self.appsink)
            self.tee.link(self.queue1)
            self.tee.link(self.queue2)

            # set pipeline playing mode
            self.pipeline_preview.set_state(Gst.State.PLAYING)
            # getting pipeline bus
            self.bus_preview = self.pipeline_preview.get_bus()
            self.bus_preview.add_signal_watch()
            self.bus_preview.connect('message::error', self.msg_error_cb)
            self.bus_preview.connect('message::eos', self.msg_eos_cb)
            self.bus_preview.connect('message::info', self.msg_info_cb)
            self.bus_preview.connect('message::application', self.msg_application_cb)
            self.bus_preview.connect('message::state-changed', self.msg_state_changed_cb)
            return True

        def camera_pipeline_preview_creation(self):
            if not ENABLE_CAMERA:
                print("Camera pipeline preview creation skipped.")
                return True
            """
            creation of the gstreamer pipeline when gstwidget is created dedicated to camera stream
            (in dual camera pipeline mode)
            """
            # gstreamer pipeline creation
            self.pipeline_preview = Gst.Pipeline()

            # creation of the source v4l2src for preview
            self.v4lsrc_preview = Gst.ElementFactory.make("v4l2src", "source_prev")
            video_device_preview = "/dev/" + str(self.app.video_device_prev)
            self.v4lsrc_preview.set_property("device", video_device_preview)
            print("device used for preview : ",video_device_preview)

            #creation of the v4l2src caps for preview
            caps_prev = str(self.app.camera_caps_prev)
            print("Camera pipeline preview configuration : ",caps_prev)
            camera1caps_prev = Gst.Caps.from_string(caps_prev)
            self.camerafilter_prev = Gst.ElementFactory.make("capsfilter", "filter_preview")
            self.camerafilter_prev.set_property("caps", camera1caps_prev)

            # creation and configuration of the queue elements
            self.queue_prev = Gst.ElementFactory.make("queue", "queue-prev")
            self.queue_prev.set_property("max-size-buffers", 1)
            self.queue_prev.set_property("leaky", 2)

            # creation of the gtkwaylandsink element to handle the gstreamer video stream
            properties_names=["drm-device"]
            properties_values=[" "]
            self.gtkwaylandsink = Gst.ElementFactory.make_with_properties("gtkwaylandsink",properties_names,properties_values)
            self.pack_start(self.gtkwaylandsink.props.widget, True, True, 0)
            self.gtkwaylandsink.props.widget.show()

            # creation and configuration of the fpsdisplaysink element to measure display fps
            self.fps_disp_sink = Gst.ElementFactory.make("fpsdisplaysink", "fpsmeasure1")
            self.fps_disp_sink.set_property("signal-fps-measurements", True)
            self.fps_disp_sink.set_property("fps-update-interval", 2000)
            self.fps_disp_sink.set_property("text-overlay", False)
            self.fps_disp_sink.set_property("video-sink", self.gtkwaylandsink)
            self.fps_disp_sink.connect("fps-measurements",self.get_fps_display)

            # Add all elements to the pipeline
            self.pipeline_preview.add(self.v4lsrc_preview)
            self.pipeline_preview.add(self.camerafilter_prev)
            self.pipeline_preview.add(self.queue_prev)
            self.pipeline_preview.add(self.fps_disp_sink)

            # linking elements together
            self.v4lsrc_preview.link(self.camerafilter_prev)
            self.camerafilter_prev.link(self.queue_prev)
            self.queue_prev.link(self.fps_disp_sink)

            # self.setup_nn_pipeline()
            # set pipeline playing mode
            # self.pipeline_preview.set_state(Gst.State.PLAYING)
            # set pipeline playing mode
            # self.pipeline_nn.set_state(Gst.State.PLAYING)
            self.bus_preview = self.pipeline_preview.get_bus()
            self.bus_preview.add_signal_watch()
            self.bus_preview.connect('message::error', self.msg_error_cb)
            self.bus_preview.connect('message::eos', self.msg_eos_cb)
            self.bus_preview.connect('message::info', self.msg_info_cb)
            self.bus_preview.connect('message::state-changed', self.msg_state_changed_cb)
            return True

        def nn_pipeline_creation(self):
            if not ENABLE_CAMERA:
                print("Camera pipeline preview creation skipped.")
                return True        
            """
            creation of the gstreamer pipeline when gstwidget is created dedicated to NN model inference
            (in dual camera pipeline mode)
            """
            self.pipeline_nn = Gst.Pipeline()

            # creation of the source v4l2src for nn
            self.v4lsrc_nn = Gst.ElementFactory.make("v4l2src", "source_nn")
            video_device_nn = "/dev/" + str(self.app.video_device_nn)
            self.v4lsrc_nn.set_property("device", video_device_nn)
            print("device used as input of the NN : ",video_device_nn)

            caps_nn_rq = str(self.app.camera_caps_nn)
            print("Camera pipeline nn requestd configuration : ",caps_nn_rq)
            camera1caps_nn_rq = Gst.Caps.from_string(caps_nn_rq)
            self.camerafilter_nn_rq = Gst.ElementFactory.make("capsfilter", "filter_nn_requested")
            self.camerafilter_nn_rq.set_property("caps", camera1caps_nn_rq)

            # creation and configuration of the queue elements
            self.queue_nn = Gst.ElementFactory.make("queue", "queue-nn")
            self.queue_nn.set_property("max-size-buffers", 1)
            self.queue_nn.set_property("leaky", 2)

            # creation and configuration of the appsink element
            self.appsink = Gst.ElementFactory.make("appsink", "appsink")
            self.appsink.set_property("caps", camera1caps_nn_rq)
            self.appsink.set_property("emit-signals", True)
            self.appsink.set_property("sync", False)
            self.appsink.set_property("max-buffers", 1)
            self.appsink.set_property("drop", True)
            self.appsink.connect("new-sample", self.new_sample)

            # Add all elements to the pipeline
            self.pipeline_nn.add(self.v4lsrc_nn)
            self.pipeline_nn.add(self.camerafilter_nn_rq)
            self.pipeline_nn.add(self.queue_nn)
            self.pipeline_nn.add(self.appsink)

            # linking elements together
            self.v4lsrc_nn.link(self.camerafilter_nn_rq)
            self.camerafilter_nn_rq.link(self.queue_nn)
            self.queue_nn.link(self.appsink)

            # getting pipeline bus
            self.bus_nn = self.pipeline_nn.get_bus()
            self.bus_nn.add_signal_watch()
            self.bus_nn.connect('message::error', self.msg_error_cb)
            self.bus_nn.connect('message::eos', self.msg_eos_cb)
            self.bus_nn.connect('message::info', self.msg_info_cb)
            self.bus_nn.connect('message::application', self.msg_application_cb)
            self.bus_nn.connect('message::state-changed', self.msg_state_changed_cb)
            return True

        def msg_eos_cb(self, bus, message):
            """
            catch gstreamer end of stream signal
            """
            print('eos message -> {}'.format(message))

        def msg_info_cb(self, bus, message):
            """
            catch gstreamer info signal
            """
            print('info message -> {}'.format(message))

        def msg_error_cb(self, bus, message):
            """
            catch gstreamer error signal
            """
            print('error message -> {}'.format(message.parse_error()))

        def msg_state_changed_cb(self, bus, message):
            """
            catch gstreamer state changed signal
            """
            oldstate,newstate,pending = message.parse_state_changed()
            if (oldstate == Gst.State.NULL) and (newstate == Gst.State.READY):
                Gst.debug_bin_to_dot_file(self.pipeline_preview, Gst.DebugGraphDetails.ALL,"pipeline_py_NULL_READY")

        def msg_application_cb(self, bus, message):
            """
            catch gstreamer application signal
            """
            if message.get_structure().get_name() == 'inference-done':
                self.app.update_ui()

        def update_isp_config(self):
            """
            Update internal ISP configuration to make the most of the camera sensor
            """
            isp_file =  "/usr/local/demo/bin/dcmipp-isp-ctrl"
            if(args.dual_camera_pipeline):
                isp_config_gamma_0 = "v4l2-ctl -d " + self.app.aux_postproc + " -c gamma_correction=0"
                isp_config_gamma_1 = "v4l2-ctl -d " + self.app.aux_postproc + " -c gamma_correction=1"
            else :
                isp_config_gamma_0 = "v4l2-ctl -d " + self.app.main_postproc + " -c gamma_correction=0"
                isp_config_gamma_1 = "v4l2-ctl -d " + self.app.main_postproc + " -c gamma_correction=1"

            isp_config_whiteb = isp_file +  " -i0 "
            isp_config_autoexposure = isp_file + " -g > /dev/null"

            if os.path.exists(isp_file) and self.app.dcmipp_sensor=="imx335" and self.isp_first_config :
                subprocess.run(isp_config_gamma_0,shell=True)
                subprocess.run(isp_config_gamma_1,shell=True)
                subprocess.run(isp_config_whiteb,shell=True)
                subprocess.run(isp_config_autoexposure,shell=True)
                self.isp_first_config = False

            if self.cpt_frame == 0 and os.path.exists(isp_file) and self.app.dcmipp_sensor=="imx335" :
                subprocess.run(isp_config_whiteb,shell=True)
                subprocess.run(isp_config_autoexposure,shell=True)

            return True

        def gst_to_nparray(self,sample):
            """
            conversion of the gstreamer frame buffer into numpy array
            """
            buf = sample.get_buffer()
            if(args.debug):
                buf_size = buf.get_size()
                buff = buf.extract_dup(0, buf.get_size())
                f=open("/home/weston/NN_sample_dump.raw", "wb")
                f.write(buff)
                f.close()
            caps = sample.get_caps()
            #get gstreamer buffer size
            buffer_size = buf.get_size()
            #determine the shape of the numpy array
            number_of_column = caps.get_structure(0).get_value('width')
            number_of_lines = caps.get_structure(0).get_value('height')
            channels = 3
            arr = np.ndarray(
                (number_of_lines,
                 number_of_column,
                 channels),
                buffer=buf.extract_dup(0, buf.get_size()),
                dtype=np.uint8)
            return arr

        def new_sample(self,*data):
            """
            recover video frame from appsink
            and run inference
            """
            sample = self.appsink.emit("pull-sample")
            arr = self.gst_to_nparray(sample)
            if(args.debug):
                cv2.imwrite("/home/weston/NN_cv_sample_dump.png",arr)
            if arr is not None :

                if self.cpt_frame == 0:
                    self.update_isp_config()

                self.cpt_frame += 1

                if self.cpt_frame == 1800:
                    self.cpt_frame = 0

                start_time = timer()
                self.nn.launch_inference(arr)
                stop_time = timer()
                self.app.nn_inference_time = stop_time - start_time
                self.app.nn_inference_fps = (1000/(self.app.nn_inference_time*1000))
                self.app.nn_result_accuracy,self.app.nn_result_label = self.nn.get_results()
                struc = Gst.Structure.new_empty("inference-done")
                msg = Gst.Message.new_application(None, struc)
                if (args.dual_camera_pipeline):
                    self.bus_nn.post(msg)
                else:
                    self.bus_preview.post(msg)
            return Gst.FlowReturn.OK

        def get_fps_display(self,fpsdisplaysink,fps,droprate,avgfps):
            """
            measure and recover display fps
            """
            self.instant_fps = fps
            return self.instant_fps

if ENABLE_DISPLAY:                  
    class MainWindow(Gtk.Window):
        """
        This class handles all the functions necessary
        to display video stream in GTK GUI or still
        pictures using OpenCVS
        """

        def __init__(self,args,app):
            """
            Setup instances of class and shared variables
            useful for the application
            """
            Gtk.Window.__init__(self)
            self.app = app
            self.main_ui_creation(args)

        def set_ui_param(self):
            """
            Setup all the UI parameter depending
            on the screen size
            """
            if self.app.window_height > self.app.window_width :
                window_constraint = self.app.window_width
            else :
                window_constraint = self.app.window_height

            self.ui_cairo_font_size = 23
            self.ui_cairo_font_size_label = 37
            self.ui_icon_exit_size = '50'
            self.ui_icon_st_size = '160'
            if window_constraint <= 272:
                   # Display 480x272
                   self.ui_cairo_font_size = 11
                   self.ui_cairo_font_size_label = 18
                   self.ui_icon_exit_size = '25'
                   self.ui_icon_st_size = '52'
            elif window_constraint <= 480:
                   #Display 800x480
                   self.ui_cairo_font_size = 16
                   self.ui_cairo_font_size_label = 29
                   self.ui_icon_exit_size = '50'
                   self.ui_icon_st_size = '80'
            elif window_constraint <= 600:
                   #Display 1024x600
                   self.ui_cairo_font_size = 19
                   self.ui_cairo_font_size_label = 32
                   self.ui_icon_exit_size = '50'
                   self.ui_icon_st_size = '120'
            elif window_constraint <= 720:
                   #Display 1280x720
                   self.ui_cairo_font_size = 23
                   self.ui_cairo_font_size_label = 38
                   self.ui_icon_exit_size = '50'
                   self.ui_icon_st_size = '160'
            elif window_constraint <= 1080:
                   #Display 1920x1080
                   self.ui_cairo_font_size = 33
                   self.ui_cairo_font_size_label = 48
                   self.ui_icon_exit_size = '50'
                   self.ui_icon_st_size = '160'

        def main_ui_creation(self,args):
            """
            Setup the Gtk UI of the main window
            """
            # remove the title bar
            self.set_decorated(False)

            self.first_drawing_call = True
            GdkDisplay = Gdk.Display.get_default()
            monitor = Gdk.Display.get_monitor(GdkDisplay, 0)
            workarea = Gdk.Monitor.get_workarea(monitor)

            GdkScreen = Gdk.Screen.get_default()
            provider = Gtk.CssProvider()
            css_path = RESOURCES_DIRECTORY + "Default.css"
            self.set_name("main_window")
            provider.load_from_path(css_path)
            Gtk.StyleContext.add_provider_for_screen(GdkScreen, provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)
            self.maximize()
            self.screen_width = workarea.width
            self.screen_height = workarea.height

            self.set_position(Gtk.WindowPosition.CENTER)
            self.connect('destroy', Gtk.main_quit)
            self.set_ui_param()
            # setup info_box containing inference results
            if self.app.enable_camera_preview == True:
                # camera preview mode
                self.info_box = Gtk.VBox()
                self.info_box.set_name("gui_main_stbox")
                self.st_icon_path = RESOURCES_DIRECTORY + 'IC_st_icon_' + self.ui_icon_st_size + 'px' + '.png'
                self.st_icon = Gtk.Image.new_from_file(self.st_icon_path)
                self.st_icon_event = Gtk.EventBox()
                self.st_icon_event.add(self.st_icon)
                self.info_box.pack_start(self.st_icon_event,False,False,2)
                self.inf_time = Gtk.Label()
                self.inf_time.set_justify(Gtk.Justification.CENTER)
                self.info_box.pack_start(self.inf_time,False,False,2)
                info_sstr = "  disp.fps :     " + "\n" + "  inf.fps :     " + "\n" + "  inf.time :     " + "\n" + "  accuracy :     " + "\n"
                self.inf_time.set_markup("<span font=\'%d\' color='#FFFFFFFF'><b>%s\n</b></span>" % (self.ui_cairo_font_size,info_sstr))

            else :
                # still picture mode
                self.info_box = Gtk.VBox()
                self.info_box.set_name("gui_main_stbox")
                self.st_icon_path = RESOURCES_DIRECTORY + 'IC_st_icon_next_inference_' + self.ui_icon_st_size + 'px' + '.png'
                self.st_icon = Gtk.Image.new_from_file(self.st_icon_path)
                self.st_icon_event = Gtk.EventBox()
                self.st_icon_event.add(self.st_icon)
                self.info_box.pack_start(self.st_icon_event,False,False,20)
                self.inf_time = Gtk.Label()
                self.inf_time.set_justify(Gtk.Justification.CENTER)
                self.info_box.pack_start(self.inf_time,False,False,2)
                info_sstr = "  inf.fps :     " + "\n" + "  inf.time :     " + "\n" + "  accuracy :     " + "\n"
                self.inf_time.set_markup("<span font=\'%d\' color='#FFFFFFFF'><b>%s\n</b></span>" % (self.ui_cairo_font_size,info_sstr))

            # setup video box containing gst stream in camera preview mode
            # and a openCV picture in still picture mode
            self.video_box = Gtk.HBox()
            self.video_box.set_name("gui_main_video")
            if self.app.enable_camera_preview == True:
                # camera preview => gst stream
                self.video_widget = self.app.gst_widget
                self.video_widget.set_app_paintable(True)
                self.video_box.pack_start(self.video_widget, True, True, 0)
            else :
                # still picture => openCV picture
                self.image = Gtk.Image()
                self.video_box.pack_start(self.image, True, True, 0)
            # setup the exit box which contains the exit button
            self.exit_box = Gtk.VBox()
            self.exit_box.set_name("gui_main_exit")
            self.exit_icon_path = RESOURCES_DIRECTORY + 'exit_' + self.ui_icon_exit_size + 'x' +  self.ui_icon_exit_size + '.png'
            self.exit_icon = Gtk.Image.new_from_file(self.exit_icon_path)
            self.exit_icon_event = Gtk.EventBox()
            self.exit_icon_event.add(self.exit_icon)
            self.exit_box.pack_start(self.exit_icon_event,False,False,2)

            # setup main box which group the three previous boxes
            self.main_box =  Gtk.HBox()
            self.exit_box.set_name("gui_main")
            self.main_box.pack_start(self.info_box,False,False,0)
            self.main_box.pack_start(self.video_box,True,True,0)
            self.main_box.pack_start(self.exit_box,False,False,0)
            self.add(self.main_box)
            return True

        def update_frame(self, frame):
            """
            update frame in still picture mode
            """
            img = Image.fromarray(frame)
            data = img.tobytes()
            data = GLib.Bytes.new(data)
            pixbuf = GdkPixbuf.Pixbuf.new_from_bytes(data,
                                                     GdkPixbuf.Colorspace.RGB,
                                                     False,
                                                     8,
                                                     frame.shape[1],
                                                     frame.shape[0],
                                                     frame.shape[2] * frame.shape[1])
            self.image.set_from_pixbuf(pixbuf.copy())

if ENABLE_DISPLAY:
    class OverlayWindow(Gtk.Window):
        """
        This class handles all the functions necessary
        to display overlayed information on top of the
        video stream and in side information boxes of
        the GUI
        """

        def __init__(self,args,app):
            """
            Setup instances of class and shared variables
            usefull for the application
            """
            Gtk.Window.__init__(self)
            self.app = app
            self.overlay_ui_creation(args)

        def exit_icon_cb(self,eventbox, event):
            """
            Exit callback to close application
            """
            self.destroy()
            Gtk.main_quit()

        def set_ui_param(self):
            """
            Setup all the UI parameter depending
            on the screen size
            """
            if self.app.window_height > self.app.window_width :
                window_constraint = self.app.window_width
            else :
                window_constraint = self.app.window_height

            self.ui_cairo_font_size = 23
            self.ui_cairo_font_size_label = 37
            self.ui_icon_exit_size = '50'
            self.ui_icon_st_size = '160'
            if window_constraint <= 272:
                   # Display 480x272
                   self.ui_cairo_font_size = 11
                   self.ui_cairo_font_size_label = 18
                   self.ui_icon_exit_size = '25'
                   self.ui_icon_st_size = '52'
            elif window_constraint <= 480:
                   #Display 800x480
                   self.ui_cairo_font_size = 16
                   self.ui_cairo_font_size_label = 29
                   self.ui_icon_exit_size = '50'
                   self.ui_icon_st_size = '80'
            elif window_constraint <= 600:
                   #Display 1024x600
                   self.ui_cairo_font_size = 19
                   self.ui_cairo_font_size_label = 32
                   self.ui_icon_exit_size = '50'
                   self.ui_icon_st_size = '120'
            elif window_constraint <= 720:
                   #Display 1280x720
                   self.ui_cairo_font_size = 23
                   self.ui_cairo_font_size_label = 38
                   self.ui_icon_exit_size = '50'
                   self.ui_icon_st_size = '160'
            elif window_constraint <= 1080:
                   #Display 1920x1080
                   self.ui_cairo_font_size = 33
                   self.ui_cairo_font_size_label = 48
                   self.ui_icon_exit_size = '50'
                   self.ui_icon_st_size = '160'

        def overlay_ui_creation(self,args):
            """
            Setup the Gtk UI of the overlay window
            """
            # remove the title bar
            self.set_decorated(False)

            self.first_drawing_call = True
            GdkDisplay = Gdk.Display.get_default()
            monitor = Gdk.Display.get_monitor(GdkDisplay, 0)
            workarea = Gdk.Monitor.get_workarea(monitor)

            GdkScreen = Gdk.Screen.get_default()
            provider = Gtk.CssProvider()
            css_path = RESOURCES_DIRECTORY + "Default.css"
            self.set_name("overlay_window")
            provider.load_from_path(css_path)
            Gtk.StyleContext.add_provider_for_screen(GdkScreen, provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)
            self.maximize()
            self.screen_width = workarea.width
            self.screen_height = workarea.height

            self.set_position(Gtk.WindowPosition.CENTER)
            self.connect('destroy', Gtk.main_quit)
            self.set_ui_param()

            # setup info_box containing inference results and ST_logo which is a
            # "next inference" button in still picture mode
            if self.app.enable_camera_preview == True:
                # camera preview mode
                self.info_box = Gtk.VBox()
                self.info_box.set_name("gui_overlay_stbox")
                self.st_icon_path = RESOURCES_DIRECTORY + 'IC_st_icon_' + self.ui_icon_st_size + 'px' + '.png'
                self.st_icon = Gtk.Image.new_from_file(self.st_icon_path)
                self.st_icon_event = Gtk.EventBox()
                self.st_icon_event.add(self.st_icon)
                self.info_box.pack_start(self.st_icon_event,False,False,2)
                self.inf_time = Gtk.Label()
                self.inf_time.set_justify(Gtk.Justification.CENTER)
                self.info_box.pack_start(self.inf_time,False,False,2)
                info_sstr = "  disp.fps :     " + "\n" + "  inf.fps :     " + "\n" + "  inf.time :     " + "\n" + "  accuracy :     " + "\n"
                self.inf_time.set_markup("<span font=\'%d\' color='#FFFFFFFF'><b>%s\n</b></span>" % (self.ui_cairo_font_size,info_sstr))
            else :
                # still picture mode
                self.info_box = Gtk.VBox()
                self.info_box.set_name("gui_overlay_stbox")
                self.st_icon_path = RESOURCES_DIRECTORY + 'IC_st_icon_next_inference_' + self.ui_icon_st_size + 'px' + '.png'
                self.st_icon = Gtk.Image.new_from_file(self.st_icon_path)
                self.st_icon_event = Gtk.EventBox()
                self.st_icon_event.add(self.st_icon)
                self.st_icon_event.connect("button_press_event",self.still_picture)
                self.info_box.pack_start(self.st_icon_event,False,False,2)
                self.inf_time = Gtk.Label()
                self.inf_time.set_justify(Gtk.Justification.CENTER)
                self.info_box.pack_start(self.inf_time,False,False,2)
                info_sstr = "  inf.fps :     " + "\n" + "  inf.time :     " + "\n" + "  accuracy :     " + "\n"
                self.inf_time.set_markup("<span font=\'%d\' color='#FFFFFFFF'><b>%s\n</b></span>" % (self.ui_cairo_font_size,info_sstr))

            # setup video box containing a transparent drawing area
            # to draw over the video stream
            self.video_box = Gtk.HBox()
            self.video_box.set_name("gui_overlay_video")
            self.video_box.set_app_paintable(True)
            self.drawing_area = Gtk.DrawingArea()
            self.drawing_area.connect("draw", self.drawing)
            self.drawing_area.set_name("overlay_draw")
            self.drawing_area.set_app_paintable(True)
            self.video_box.pack_start(self.drawing_area, True, True, 0)

            # setup the exit box which contains the exit button
            self.exit_box = Gtk.VBox()
            self.exit_box.set_name("gui_overlay_exit")
            self.exit_icon_path = RESOURCES_DIRECTORY + 'exit_' + self.ui_icon_exit_size + 'x' +  self.ui_icon_exit_size + '.png'
            self.exit_icon = Gtk.Image.new_from_file(self.exit_icon_path)
            self.exit_icon_event = Gtk.EventBox()
            self.exit_icon_event.add(self.exit_icon)
            self.exit_icon_event.connect("button_press_event",self.exit_icon_cb)
            self.exit_box.pack_start(self.exit_icon_event,False,False,2)

            # setup main box which group the three previous boxes
            self.main_box =  Gtk.HBox()
            self.exit_box.set_name("gui_overlay")
            self.main_box.pack_start(self.info_box,False,False,0)
            self.main_box.pack_start(self.video_box,True,True,0)
            self.main_box.pack_start(self.exit_box,False,False,0)
            self.add(self.main_box)
            return True

        def drawing(self, widget, cr):
            """
            Drawing callback used to draw with cairo on
            the drawing area
            """
            if self.app.first_drawing_call :
                self.app.first_drawing_call = False
                self.drawing_width = widget.get_allocated_width()
                self.drawing_height = widget.get_allocated_height()
                cr.set_font_size(self.ui_cairo_font_size)
                self.label_printed = True
                if self.app.enable_camera_preview == False :
                    self.app.still_picture_next = True
                    if args.validation:
                        GLib.idle_add(self.app.process_picture)
                    else:
                        self.app.process_picture()
                return False
            if (self.app.label_to_display == ""):
                # waiting screen
                text = "Loading NN model"
                cr.set_font_size(self.ui_cairo_font_size*3)
                xbearing, ybearing, width, height, xadvance, yadvance = cr.text_extents(text)
                cr.move_to((self.drawing_width/2-width/2),(self.drawing_height/2))
                cr.text_path(text)
                cr.set_source_rgb(0.012,0.137,0.294)
                cr.fill_preserve()
                cr.set_source_rgb(1, 1, 1)
                cr.set_line_width(0.2)
                cr.stroke()
                return True
            else :
                cr.set_font_size(self.ui_cairo_font_size_label)
                self.label_printed = True
                if args.validation:
                    self.app.still_picture_next = True
                # running screen
                xbearing, ybearing, width, height, xadvance, yadvance = cr.text_extents(self.app.label_to_display)
                cr.move_to((self.drawing_width/2-width/2),((9/10)*self.drawing_height))
                cr.text_path(self.app.label_to_display)
                cr.set_source_rgb(1, 1, 1)
                cr.fill_preserve()
                cr.set_source_rgb(0, 0, 0)
                cr.set_line_width(0.7)
                cr.stroke()
                return True

        def still_picture(self,  widget, event):
            """
            ST icon cb which trigger a new inference
            """
            self.app.still_picture_next = True
            return self.app.process_picture()

class Application:
    """
    Class that handles the whole application
    """
    def __init__(self, args):
        # Define paths for classification and confidence files as instance variables
        self.classification_file_path = '/usr/iotc/local/data/classification'
        self.confidence_file_path = '/usr/iotc/local/data/confidence'  # Correctly define confidence file path
        self.unique_pair_file = "/usr/iotc/local/data/last_classification_confidence.txt"  # Unique pair file path
        
        # Other initializations...
        self.download_path = "/tmp/downloaded_image.jpg"
        
        #init variables uses :
        self.exit_app = False
        self.dcmipp_camera = False
        self.first_drawing_call = True
        self.first_call = True
        self.window_width = 0
        self.window_height = 0
        self.get_display_resolution()

        #instantiate the Neural Network class
        self.nn = NeuralNetwork(args.model_file, args.label_file, float(args.input_mean), float(args.input_std))
        self.shape = self.nn.get_img_size()
        self.nn_input_width = self.shape[1]
        self.nn_input_height = self.shape[0]
        self.nn_input_channel = self.shape[2]
        self.nn_inference_time = 0.0
        self.nn_inference_fps = 0.0
        self.nn_result_accuracy = 0.0
        self.nn_result_label = 0
        self.label_to_display = ""
        
        # Conditionally initialize the camera and display
        if ENABLE_CAMERA:
            self.gst_widget = GstWidget(self, self.nn)
        else:
            print("Camera initialization skipped.")
        #if args.image is empty -> camera preview mode else still picture
        if args.image == "":
            print("camera preview mode activate")
            self.enable_camera_preview = True
            #Test if a camera is connected
            check_camera_cmd = RESOURCES_DIRECTORY + "check_camera_preview.sh"
            check_camera = subprocess.run(check_camera_cmd)
            if check_camera.returncode==1:
                print("no camera connected")
                exit(1)
            if(args.dual_camera_pipeline):
                self.video_device_prev,self.camera_caps_prev,self.video_device_nn,self.camera_caps_nn,self.dcmipp_sensor, self.aux_postproc = self.setup_camera()
            else:
                self.video_device_prev,self.camera_caps_prev,self.dcmipp_sensor, self.main_postproc = self.setup_camera()
        else:
            print("still picture mode activate")
            self.enable_camera_preview = False
            self.still_picture_next = False
        # initialize the list of the file to be processed (used with the
        # --image parameter)
        self.files = []
        # initialize the list of inference/display time to process the average
        # (used with the --validation parameter)
        self.valid_inference_time = []
        self.valid_inference_fps = []
        self.valid_preview_fps = []
        self.valid_draw_count = 0

        if ENABLE_DISPLAY:
            #instantiate the Gstreamer pipeline
            self.gst_widget = GstWidget(self,self.nn)
            #instantiate the main window
            self.main_window = MainWindow(args,self)
            #instantiate the overlay window
            self.overlay_window = OverlayWindow(args,self)
            self.main()
        else:
            print("Display components skipped.")

    def get_device_identifier(self):
        """
        Retrieves the device identifier from the config.json file.
        Combines 'duid' and 'cpid' to form a unique identifier.
        Writes the unique identifier to '/usr/iotc/local/data/unique_id'.
        """
        config_file_path = '/usr/iotc/local/config.json'
        unique_id_file_path = '/usr/iotc/local/data/unique_id'  # Path to store unique ID

        try:
            # Read the configuration file
            with open(config_file_path, 'r') as config_file:
                config = json.load(config_file)
                duid = config.get("duid", "unknown_duid")
                cpid = config.get("cpid", "unknown_cpid")
                device_identifier = f"{duid}-{cpid}"
                
                # Write the device identifier to 'unique_id' file
                with open(unique_id_file_path, 'w') as unique_id_file:
                    unique_id_file.write(device_identifier)
                
                print(f"Device identifier '{device_identifier}' written to '{unique_id_file_path}'")
                return device_identifier

        except Exception as e:
            print(f"Error reading config file or writing unique ID: {e}")
            return "unknown_duid-unknown_cpid"

    def download_image_from_s3(self, image_url):
        """
        Downloads an image from a public S3 URL.
        """
        try:
            response = requests.get(image_url)
            if response.status_code == 200:
                with open(self.download_path, 'wb') as file:
                    file.write(response.content)
                print(f"Downloaded {image_url}")
                return self.download_path
            else:
                print(f"Failed to download image, status code: {response.status_code}")
                return None
        except Exception as e:
            print(f"Error downloading image: {e}")
            return None
            
    def download_log_from_s3(self, log_url):
        """
        Downloads the existing log file from a public S3 URL.
        """
        try:
            response = requests.get(log_url)
            if response.status_code == 200:
                return response.text  # Returning the log file contents as a string
            else:
                print(f"Failed to download log file, status code: {response.status_code}")
                return ""
        except Exception as e:
            print(f"Error downloading log file: {e}")
            return ""

    def upload_log_to_s3(self, log_data, log_url):
        """
        Uploads the updated log to a public S3 URL if allowed.
        """
        try:
            response = requests.put(log_url, data=log_data)
            if response.status_code == 200:
                print("Log file uploaded successfully.")
            else:
                print(f"Failed to upload log, status code: {response.status_code}")
        except Exception as e:
            print(f"Error uploading log: {e}")

    def classify_s3_image(self):
        """
        Download `bottom.jpg` from S3, classify it using NPU, and log the classification label and confidence.
        Write classification label and confidence to separate files, and update the log with both.
        Only logs unique classification-confidence pairs per device.
        """
        device_identifier = self.get_device_identifier()

        # Initialize default values for label and confidence
        label = "Unknown"
        confidence = 0.0

        # Download the image from S3
        image_path = self.download_image_from_s3(BOTTOM_IMAGE_URL)
        if image_path is None:
            print("Failed to download the image.")
            return

        # Load the image and prepare for inference
        img = cv2.imread(image_path)
        if img is None:
            print("Failed to load image.")
            return
        img_resized = cv2.resize(img, (self.nn_input_width, self.nn_input_height))

        # Perform inference
        try:
            self.nn.launch_inference(img_resized)
            accuracy, label_index = self.nn.get_results()
            labels = self.nn.get_labels()
            label = labels[label_index] if labels else "Unknown"
            confidence = accuracy * 100  # Convert to percentage
            print(f"Classification: {label}, Confidence: {confidence:.2f}%")
        except Exception as e:
            print(f"Error during NPU inference: {e}")

        # Write classification and confidence to local files
        try:
            with open(self.classification_file_path, 'w') as f_classification:
                f_classification.write(label)
            with open(self.confidence_file_path, 'w') as f_confidence:
                f_confidence.write(f"{confidence:.2f}")
            print(f"Classification and confidence written to files: {label}, {confidence:.2f}%")
        except Exception as e:
            print(f"Error writing classification/confidence to files: {e}")

        # Check if the current classification-confidence pair is different for the current device
        new_pair = f"{label}, {confidence:.2f}%"
        unique_device_pair_file = f"{self.unique_pair_file}_{device_identifier}"  # Unique file per device

        # Read the last unique pair from the device-specific file, if it exists
        try:
            with open(unique_device_pair_file, 'r') as f_last_pair:
                last_pair = f_last_pair.read().strip()
        except FileNotFoundError:
            last_pair = ""  # If the file doesn't exist, assume no prior pair

        if new_pair != last_pair:
            # Only log if the new pair is unique for this device
            timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            new_log_entry = f"{device_identifier}, {timestamp}, {label}, {confidence:.2f}%\n"

            # Fetch existing log content from S3
            existing_log = self.download_log_from_s3(LOG_FILE_URL)
            updated_log = new_log_entry + existing_log  # Prepend the new entry

            # Upload updated log back to S3
            self.upload_log_to_s3(updated_log, LOG_FILE_URL)
            print("New unique entry added to log.")

            # Update the last classification-confidence pair file for this device
            with open(unique_device_pair_file, 'w') as f_last_pair:
                f_last_pair.write(new_pair)
        else:
            print("Duplicate entry detected for this device; not logging.")

    def run(self):
        """
        Continuously download an image, classify it, and repeat every 5 seconds.
        """
        while True:
            print("Starting classification cycle...")
            self.classify_s3_image()
            time.sleep(5)
    
    def process_picture(self):
        """
        Still picture inference function
        Load the frame, launch inference and
        call functions to refresh UI
        """
        if self.exit_app:
            Gtk.main_quit()
            return False

        if self.still_picture_next and self.overlay_window.label_printed:
            # Ensure args.image is not None
            if not args.image:
                print("No image provided or image path is None.")
                return
            # get randomly a picture in the directory
            rfile = self.getRandomFile(args.image)
            img = Image.open(args.image + rfile)
            if args.image is None:
                print("No image provided")
                return

            # recover drawing box size and picture size
            screen_width = self.overlay_window.drawing_width
            screen_height = self.overlay_window.drawing_height
            picture_width, picture_height = img.size

            #adapt the frame to the screen with with the preservation of the aspect ratio
            width_ratio = float(screen_width/picture_width)
            height_ratio = float(screen_height/picture_height)

            if width_ratio >= height_ratio :
                self.frame_height = height_ratio * picture_height
                self.frame_width = height_ratio * picture_width
            else :
                self.frame_height = width_ratio * picture_height
                self.frame_width = width_ratio * picture_width

            self.frame_height = int(self.frame_height)
            self.frame_width = int(self.frame_width)
            prev_frame = cv2.resize(np.array(img), (self.frame_width, self.frame_height))

            # update the preview frame
            self.main_window.update_frame(prev_frame)
            self.overlay_window.label_printed = False

            #resize the frame to feed the NN model
            nn_frame = cv2.resize(np.array(img), (self.nn_input_width, self.nn_input_height))
            start_time = timer()
            self.nn.launch_inference(nn_frame)
            stop_time = timer()
            self.still_picture_next = False
            self.nn_inference_time = stop_time - start_time
            self.nn_inference_fps = (1000/(self.nn_inference_time*1000))
            self.nn_result_accuracy, self.nn_result_label = self.nn.get_results()

            # write information onf the GTK UI
            labels = self.nn.get_labels()
            label = labels[self.nn_result_label]
            accuracy = self.nn_result_accuracy * 100
            inference_time = self.nn_inference_time * 1000

            if args.validation and inference_time != 0:
                # reload the timeout
                GLib.source_remove(self.valid_timeout_id)
                self.valid_timeout_id = GLib.timeout_add(100000,
                                                         self.valid_timeout_callback)
                # get file name
                file_name = os.path.basename(rfile)
                # remove the extension
                file_name = os.path.splitext(file_name)[0]
                # remove eventual '_'
                file_name = file_name.rsplit('_')[0]
                # store the inference time in a list so that we can compute the
                # average later on
                if self.first_call :
                    #skip first inference time to avoid warmup time in NPU
                    self.first_call = False
                else :
                    self.valid_inference_time.append(round(self.nn_inference_time * 1000, 4))
                print("name extract from the picture file: {0:32} label {1}".format(file_name, str(label)))
                if label not in file_name :
                    print("Inference result mismatch the file name")
                    os._exit(5)
                # process all the file
                if len(self.files) == 0:
                    avg_inf_time = sum(self.valid_inference_time) / len(self.valid_inference_time)
                    avg_inf_time = round(avg_inf_time,4)
                    print("avg inference time= " + str(avg_inf_time) + " ms")
                    self.exit_app = True
            #update label
            self.update_label_still(label,accuracy,inference_time)
            self.main_window.queue_draw()
            self.overlay_window.queue_draw()
            return True
        else :
            return False

    def get_display_resolution(self):
        """
        Used to ask the system for the display resolution
        """
        if ENABLE_DISPLAY:
            cmd = "modetest -M stm -c > /tmp/display_resolution.txt"
            subprocess.run(cmd,shell=True)
            display_info_pattern = "#0"
            display_information = ""
            display_resolution = ""
            display_width = ""
            display_height = ""

            f = open("/tmp/display_resolution.txt", "r")
            for line in f :
                if display_info_pattern in line:
                    display_information = line
            display_information_splited = display_information.split()
            for i in display_information_splited :
                if "x" in i :
                    display_resolution = i
            display_resolution = display_resolution.replace('x',' ')
            display_resolution = display_resolution.split()
            display_width = display_resolution[0]
            display_height = display_resolution[1]

            print("display resolution is : ",display_width, " x ", display_height)
            self.window_width = int(display_width)
            self.window_height = int(display_height)
            return 0
        else:
            print("Display components skipped.")
            return 0

    def setup_camera(self):
        """
        Used to configure the camera based on resolution passed as application arguments
        """
        width = str(args.frame_width)
        height = str(args.frame_height)
        framerate = str(args.framerate)
        device = str(args.video_device)
        nn_input_width = str(self.nn_input_width)
        nn_input_height = str(self.nn_input_height)
        if (args.dual_camera_pipeline):
            config_camera = RESOURCES_DIRECTORY + "setup_camera.sh " + width + " " + height + " " + framerate + " " + nn_input_width + " " + nn_input_height + " " + device
        else:
            config_camera = RESOURCES_DIRECTORY + "setup_camera.sh " + width + " " + height + " " + framerate + " " + device
        x = subprocess.check_output(config_camera,shell=True)
        x = x.decode("utf-8")
        print(x)
        x = x.split("\n")
        for i in x :
            if "V4L_DEVICE_PREV" in i:
                video_device_prev = i.lstrip('V4L_DEVICE_PREV=')
            if "V4L2_CAPS_PREV" in i:
                camera_caps_prev = i.lstrip('V4L2_CAPS_PREV=')
            if "V4L_DEVICE_NN" in i:
                video_device_nn = i.lstrip('V4L_DEVICE_NN=')
            if "V4L2_CAPS_NN" in i:
                camera_caps_nn = i.lstrip('V4L2_CAPS_NN=')
            if "DCMIPP_SENSOR" in i:
                dcmipp_sensor = i.lstrip('DCMIPP_SENSOR=')
            if "MAIN_POSTPROC" in i:
                main_postproc = i.lstrip('MAIN_POSTPROC=')
            if "AUX_POSTPROC" in i:
                aux_postproc = i.lstrip('AUX_POSTPROC=')
        if (args.dual_camera_pipeline):
            return video_device_prev, camera_caps_prev,video_device_nn,camera_caps_nn, dcmipp_sensor, aux_postproc
        else:
            return video_device_prev, camera_caps_prev, dcmipp_sensor, main_postproc

    def valid_timeout_callback(self):
        """
        if timeout occurs that means that camera preview and the gtk is not
        behaving as expected
        """
        print("Timeout: camera preview and/or gtk is not behaving has expected\n")
        Gtk.main_quit()
        os._exit(1)

    # get random file in a directory
    def getRandomFile(self, path):
        """
        Returns a random filename, chosen among the files of the given path.
        """
        if len(self.files) == 0:
            self.files = os.listdir(path)

        if len(self.files) == 0:
            return ''

        # remove .json file
        item_to_remove = []
        for item in self.files:
            if item.endswith(".json"):
                item_to_remove.append(item)

        for item in item_to_remove:
            self.files.remove(item)

        index = random.randrange(0, len(self.files))
        file_path = self.files[index]
        self.files.pop(index)
        return file_path

    def load_valid_results_from_json_file(self, json_file):
        """
        Load json files containing expected results for the validation mode
        """
        json_file = json_file + '.json'
        name = []
        x0 = []
        y0 = []
        x1 = []
        y1 = []
        with open(args.image + "/" + json_file) as json_file:
            data = json.load(json_file)
            for obj in data['objects_info']:
                name.append(obj['name'])
                x0.append(obj['x0'])
                y0.append(obj['y0'])
                x1.append(obj['x1'])
                y1.append(obj['y1'])

        return name, x0, y0, x1, y1

    # Updating the labels and the inference infos displayed on the GUI interface - camera input
    def update_label_preview(self):
        """
        Updating the labels and the inference infos displayed on the GUI interface - camera input
        """
        inference_time = self.nn_inference_time * 1000
        inference_fps = self.nn_inference_fps
        display_fps = self.gst_widget.instant_fps
        labels = self.nn.get_labels()
        label = labels[self.nn_result_label]
        accuracy = self.nn_result_accuracy * 100

        # Get classification label and confidence (accuracy)
        inference_time = self.nn_inference_time * 1000  # Inference time in milliseconds
        labels = self.nn.get_labels()
        label = labels[self.nn_result_label]  # Get classification label
        accuracy = self.nn_result_accuracy * 100  # Confidence as a percentage
        
        # Debugging: Print classification and confidence
        print(f"Classification: {label}")
        print(f"Confidence: {accuracy:.2f}%")
        
        # Read the threshold confidence level from set-conf-level
        with open('/usr/iotc/local/data/set-conf-level', 'r') as f_conf_level:
            conf_level = float(f_conf_level.read().strip())
        
        print(f"Confidence threshold from set-conf-level: {conf_level}")
        
        # Check if confidence meets or exceeds the threshold
        if accuracy >= conf_level:
            # Write classification to file
            with open('/usr/iotc/local/data/classification', 'w') as f_classification:
                f_classification.write(label)
            
            # Write confidence to file
            with open('/usr/iotc/local/data/confidence', 'w') as f_confidence:
                f_confidence.write(f"{accuracy:.2f}")
            
            print("Classification and confidence written to files successfully.")
        else:
            print(f"Confidence {accuracy:.2f}% is below the threshold {conf_level}, skipping file write.")        

        if (args.validation) and (inference_time != 0) and (self.valid_draw_count > 5):
            self.valid_preview_fps.append(round(self.gst_widget.instant_fps))
            self.valid_inference_time.append(round(self.nn_inference_time * 1000, 4))

        str_inference_time = str("{0:0.1f}".format(inference_time)) + " ms"
        str_display_fps = str("{0:.1f}".format(display_fps)) + " fps"
        str_inference_fps = str("{0:.1f}".format(inference_fps)) + " fps"
        str_accuracy = str("{0:.2f}".format(accuracy)) + " %"

        info_sstr = "  disp.fps :     " + "\n" + str_display_fps + "\n" + "  inf.fps :     " + "\n" + str_inference_fps + "\n" + "  inf.time :     " + "\n"  + str_inference_time + "\n" + "  accuracy :     " + "\n" + str_accuracy

        self.overlay_window.inf_time.set_markup("<span font=\'%d\' color='#FFFFFFFF'><b>%s\n</b></span>" % (self.overlay_window.ui_cairo_font_size,info_sstr))

        self.label_to_display = label

        if args.validation:
            # reload the timeout
            GLib.source_remove(self.valid_timeout_id)
            self.valid_timeout_id = GLib.timeout_add(10000,
                                                     self.valid_timeout_callback)

            self.valid_draw_count = self.valid_draw_count + 1
            # stop the application after defined amount of draws
            if self.valid_draw_count > int(args.val_run):
                avg_prev_fps = sum(self.valid_preview_fps) / len(self.valid_preview_fps)
                avg_inf_time = sum(self.valid_inference_time) / len(self.valid_inference_time)
                avg_inf_fps = (1000/avg_inf_time)
                print("avg display fps= " + str(avg_prev_fps))
                print("avg inference fps= " + str(avg_inf_fps))
                print("avg inference time= " + str(avg_inf_time) + " ms")
                GLib.source_remove(self.valid_timeout_id)
                Gtk.main_quit()
                return True
        return True

    def update_label_still(self, label, accuracy, inference_time):
        """
        update inference results in still picture mode
        """
        str_accuracy = str("{0:.2f}".format(accuracy)) + " %"
        str_inference_time = str("{0:0.1f}".format(inference_time)) + " ms"
        inference_fps = 1000/inference_time
        str_inference_fps = str("{0:.1f}".format(inference_fps)) + " fps"
        info_sstr ="  inf.fps :     " + "\n" + str_inference_fps + "\n" + "  inf.time :     " + "\n"  + str_inference_time + "\n" + "  accuracy :     " + "\n" + str_accuracy
        self.overlay_window.inf_time.set_markup("<span font=\'%d\' color='#FFFFFFFF'><b>%s\n</b></span>" % (self.main_window.ui_cairo_font_size,info_sstr))
        self.label_to_display = label

    def update_ui(self):
        """
        refresh overlay UI
        """
        self.update_label_preview()
        self.main_window.queue_draw()
        self.overlay_window.queue_draw()

    def main(self):
        self.main_window.connect("delete-event", Gtk.main_quit)
        self.main_window.show_all()
        self.overlay_window.connect("delete-event", Gtk.main_quit)
        self.overlay_window.show_all()
        # start a timeout timer in validation process to close application if
        # timeout occurs
        if args.validation:
            self.valid_timeout_id = GLib.timeout_add(100000,
                                                     self.valid_timeout_callback)
        return True


# Main function
if __name__ == '__main__':
    try:
        # Initialize the neural network model and application
        application = Application(args)
        
        # Conditionally start GTK main loop if display is enabled
        if ENABLE_DISPLAY:
            Gtk.main()
        else:
            application.run()
    except Exception as exc:
        print("Main Exception: ", exc)
    
    print("Application exited properly")
    os._exit(0)
