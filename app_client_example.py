import socketio
import base64

# Create a Socket.IO client instance
sio = socketio.Client()

@sio.event
def connect():
    print('Connected to server')
    send_image()

@sio.event
def connect_error(data):
    print(f"Connection failed: {data}")

@sio.event
def disconnect():
    print('Disconnected from server')

@sio.on('response')
def on_response(data):
    print(f"Server response: {data}")

def send_image():
    # Path to the image file
    image_path = 'image.jpg'

    # Read and encode the image as base64
    with open(image_path, "rb") as image_file:
        encoded_string = base64.b64encode(image_file.read()).decode('utf-8')

    # Send the encoded image data to the server
    sio.emit('image_data', {'image': encoded_string})

if __name__ == '__main__':
    # Connect to the WebSocket server
    sio.connect('http://localhost:5000')
    sio.wait()
