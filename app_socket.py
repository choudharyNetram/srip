from flask import Flask, request, jsonify
from flask_socketio import SocketIO, emit
import cv2
import numpy as np
import tensorflow as tf
import base64
from PIL import Image, UnidentifiedImageError
from io import BytesIO
import os
import json

app = Flask(__name__)
socketio = SocketIO(app)

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

@socketio.on('connect')
def handle_connect():
    print('Client connected')

@socketio.on('disconnect')
def handle_disconnect():
    print('Client disconnected')

@app.errorhandler(400)
def bad_request(error):
    return jsonify({"error": "Bad request"}), 400

@app.errorhandler(404)
def not_found(error):
    return jsonify({"error": "Not found"}), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({"error": "Internal server error"}), 500



@socketio.on('message')
def handle_message(data):
    data = json.loads(data)
    if 'image' not in data:
        emit('response', {'error': 'No image data provided'})
        return

    # Decode base64 image string
    base64_image = data['image']
    try:
        print('starting decoding image')
        image_bytes = base64.b64decode(base64_image)
        image = Image.open(BytesIO(image_bytes)).convert('RGB')
        image = image.rotate(90, expand=True)
        image = np.array(image)
        print('data aa gya')
    except (UnidentifiedImageError, Exception) as e:
        emit('response', {'error': f'Error: Could not decode image data: {str(e)}'})
        return

    try: 
        gray = cv2.cvtColor(image, cv2.COLOR_RGB2GRAY)
        faces = face_cascade.detectMultiScale(gray, scaleFactor=1.3, minNeighbors=5)
    except Exception as e:
        emit('response', {'error': "Could not detect face and couldn't change color"})
        return

    predictions = []
    print(faces)
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
            print(pred)
            max_value = np.amax(pred[0])
            result = np.where(pred[0] == max_value)[0][0]
            
            predictions.append({
                "eye_position": "left" if ex < w/2 else "right",
                "prediction": int(result),
                "confidence": float(max_value)
            })
    
    print(predictions)
    emit('response', predictions)


if __name__ == '__main__':
    socketio.run(app, host='0.0.0.0', port=5000)
