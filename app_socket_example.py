from flask import Flask
from flask_socketio import SocketIO, emit
import base64

app = Flask(__name__)
socketio = SocketIO(app)

@socketio.on('connect')
def handle_connect():
    print('Client connected')

@socketio.on('disconnect')
def handle_disconnect():
    print('Client disconnected')

@socketio.on('image_data')
def handle_image_data(data):
    print('Received image data')
    image_data = data.get('image')
    if image_data:
        # Decode the base64 string to bytes
        image_bytes = base64.b64decode(image_data)
        with open("received_image.jpg", "wb") as f:
            f.write(image_bytes)
        print('Image saved successfully')
        emit('response', {'data': 'Image received and saved!'})
    else:
        emit('response', {'data': 'No image data received'})

if __name__ == '__main__':
    socketio.run(app, host='0.0.0.0', port=5000, debug=True)
