from flask import Flask, request, jsonify
import cv2
import numpy as np
import tensorflow as tf
import base64
from PIL import Image
from io import BytesIO
import os


# if img is None:
#     raise FileNotFoundError("Image file 'image1.jpg' not found")
app = Flask(__name__)

# Load pre-trained models
face_cascade = cv2.CascadeClassifier("haarcascade_frontalface_default.xml")
eye_cascade = cv2.CascadeClassifier("haarcascade_eye.xml")
model = tf.keras.models.load_model('saved_model_1/saved_model_1/saved_model.h5')


def CustomParser(data):    
    j = np.asarray(data, dtype="int32").flatten()
    return j

@app.route('/')
def index():
    return "Hello, world!"

@app.route('/predict', methods=['POST'])
def predict():
    data = request.get_json()
    if 'image_path' not in data:
        return jsonify({"error": "No image data provided"}), 400
    
    # Decode base64 image string
    # base64_image = data['image']
    # image_bytes = base64.b64decode(base64_image)
    # image = Image.open(BytesIO(image_bytes))
    # image = np.array(image)

    # gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    # faces = face_cascade.detectMultiScale(gray, scaleFactor=1.3, minNeighbors=5)

    os.chdir("C:/Users/choud/App_dev/flutter_application_1")
    img = cv2.imread(data['image_path'])
    #img = Image.open("C:/Users/choud/App_dev/flutter_application_1/image1")
    img=cv2.flip(img,1)         
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    faces = face_cascade.detectMultiScale(gray, scaleFactor=1.3, minNeighbors=5)

    predictions = []

    for (x, y, w, h) in faces:
        face_roi = gray[y:y+h, x:x+w]
        eyes = eye_cascade.detectMultiScale(face_roi)
        for (ex, ey, ew, eh) in eyes:
            eye_roi = face_roi[ey:ey+eh, ex:ex+ew]
            eye_roi = cv2.resize(eye_roi, (100, 100), interpolation=cv2.INTER_LINEAR)
            
            image_shape = np.expand_dims(eye_roi, axis=-1).shape
            data = CustomParser(eye_roi)
            data = np.asarray([np.asarray(data.reshape(image_shape))])
            data = data / 255
            pred = model.predict(data)
            max_value = np.amax(pred[0])
            result = np.where(pred[0] == max_value)[0][0]
            predictions.append({
                "eye_position": "left" if ex < w/2 else "right",
                "prediction": int(result),
                "confidence": float(max_value)
            })
    
    return jsonify(predictions)

if __name__ == '__main__':
    app.run(debug=True)
from flask import Flask, request, jsonify
import cv2
import numpy as np
import tensorflow as tf
import base64
from PIL import Image
from io import BytesIO
import os


# if img is None:
#     raise FileNotFoundError("Image file 'image1.jpg' not found")
app = Flask(__name__)

# Load pre-trained models
face_cascade = cv2.CascadeClassifier("haarcascade_frontalface_default.xml")
eye_cascade = cv2.CascadeClassifier("haarcascade_eye.xml")
model = tf.keras.models.load_model('saved_model_1/saved_model_1/saved_model.h5')


def CustomParser(data):    
    j = np.asarray(data, dtype="int32").flatten()
    return j

@app.route('/')
def index():
    return "Hello, world!"

@app.route('/predict', methods=['POST'])
def predict():
    data = request.get_json()
    if 'image_path' not in data:
        return jsonify({"error": "No image data provided"}), 400
    
    # Decode base64 image string
    # base64_image = data['image']
    # image_bytes = base64.b64decode(base64_image)
    # image = Image.open(BytesIO(image_bytes))
    # image = np.array(image)

    # gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    # faces = face_cascade.detectMultiScale(gray, scaleFactor=1.3, minNeighbors=5)

    os.chdir("C:/Users/choud/App_dev/flutter_application_1")
    img = cv2.imread(data['image_path'])
    #img = Image.open("C:/Users/choud/App_dev/flutter_application_1/image1")
    img=cv2.flip(img,1)         
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    faces = face_cascade.detectMultiScale(gray, scaleFactor=1.3, minNeighbors=5)

    predictions = []

    for (x, y, w, h) in faces:
        face_roi = gray[y:y+h, x:x+w]
        eyes = eye_cascade.detectMultiScale(face_roi)
        for (ex, ey, ew, eh) in eyes:
            eye_roi = face_roi[ey:ey+eh, ex:ex+ew]
            eye_roi = cv2.resize(eye_roi, (100, 100), interpolation=cv2.INTER_LINEAR)
            
            image_shape = np.expand_dims(eye_roi, axis=-1).shape
            data = CustomParser(eye_roi)
            data = np.asarray([np.asarray(data.reshape(image_shape))])
            data = data / 255
            pred = model.predict(data)
            max_value = np.amax(pred[0])
            result = np.where(pred[0] == max_value)[0][0]
            predictions.append({
                "eye_position": "left" if ex < w/2 else "right",
                "prediction": int(result),
                "confidence": float(max_value)
            })
    
    return jsonify(predictions)

if __name__ == '__main__':
    app.run(debug=True)
