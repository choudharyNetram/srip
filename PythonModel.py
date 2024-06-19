import cv2
import numpy as np
from tensorflow import keras
from PIL import Image



face_cascade = cv2.CascadeClassifier("haarcascade_frontalface_default.xml")
eye_cascade = cv2.CascadeClassifier("haarcascade_eye.xml")
model = keras.models.load_model('saved_model_1/saved_model_1')



def CustomParser(data):    
    j = np.asarray(data, dtype="int32").flatten()
    return j

#camera= cv2.VideoCapture(0)
#return_value, image=camera.read()
import os
os.chdir("C:/Users/choud/App_dev/flutter_application_1")
img = cv2.imread('image.jpg')
#img = Image.open("C:/Users/choud/App_dev/flutter_application_1/image1")


# if img is None:
#     raise FileNotFoundError("Image file 'image1.jpg' not found")
img=cv2.flip(img,1)         
gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
faces = face_cascade.detectMultiScale(gray, scaleFactor=1.3, minNeighbors=5)

for (x, y, w, h) in faces:
    face_roi = gray[y:y+h, x:x+w]
    eyes = eye_cascade.detectMultiScale(face_roi)
    for (ex, ey, ew, eh) in eyes:
        if ex < w/2:  # Left eye
            eye_roi = face_roi[ey:ey+eh, ex:ex+ew]
            eye_roi = cv2.resize(eye_roi, (100, 100), interpolation=cv2.INTER_LINEAR)
            
            image_shape = np.expand_dims(eye_roi, axis=-1).shape
            data = CustomParser(eye_roi)
            data = np.asarray([np.asarray(data.reshape(image_shape))])
            data = data / 255
            predictions = model.predict(data)
            max_value = np.amax(predictions[0])
            result = np.where(predictions[0] == np.amax(predictions[0]))[0]
            eye1=result
            print(predictions)
            # selected = result

        else:  # Right eye
            eye_roi = face_roi[ey:ey+eh, ex:ex+ew]
            eye_roi = cv2.resize(eye_roi, (100, 100), interpolation=cv2.INTER_LINEAR)
            
            image_shape = np.expand_dims(eye_roi, axis=-1).shape
            data = CustomParser(eye_roi)
            data = np.asarray([np.asarray(data.reshape(image_shape))])
            data = data / 255
            predictions = model.predict(data)
            max_value = np.amax(predictions[0])
            result = np.where(predictions[0] == np.amax(predictions[0]))[0]
            eye2=result
            selected = result
            print(predictions)
            # print(result)