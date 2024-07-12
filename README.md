# Real-Time Assistive Typing Mobile Application with CNN and OpenCV-Enhanced Server

This project implements a real-time typing application using Flutter for the frontend and a Python backend powered by Flask and various libraries. It leverages CNNs (Convolutional Neural Networks) for prediction and OpenCV for image processing, enabling an efficient and accurate user experience.

### Key Features:

* Real-time typing with high prediction accuracy
* User-friendly virtual keyboard interface
* Calibration window for personalized model fine-tuning
* Efficient communication between frontend and backend using SocketIO

### Tech Stack:

* **Frontend (Flutter):**
    * Cross-platform development for consistent user experience across devices
    * Virtual keyboard for real-time interaction
    * Calibration Window for Fine-tuning of model
    * Communication with backend server through SocketIO
* **Backend (Python):**
    * Flask for lightweight and efficient web framework
    * OpenCV for image processing tasks like face and eye detection
    * NumPy for numerical computations
    * TensorFlow for machine learning model implementation (CNN)
    * Pillow for image manipulation
    * Scikit-learn for machine learning utilities 
    * Keras for deep learning 
    * Eventlet for asynchronous task handling 

**Installation:**

**1. Python Backend:**

## Installation (Python Backend)

You'll need the following Python libraries for the backend server:

```bash
pip install Flask Flask-SocketIO opencv-python numpy tensorflow Pillow matplotlib pandas scikit-learn keras eventlet
```

**2. Flutter Frontend:**

Add the following dependencies to your `pubspec.yaml` file:

```yaml
dependencies:
  camera: ^0.11.0+2
  flutter:
    sdk: flutter
  provider: ^6.0.0
  path_provider: ^2.1.3
  image_picker: ^1.1.1
  image: ^4.2.0
  socket_io_client: ^2.0.3+1
```
Then Run: 
flutter pub get


### For Running the Application 

1. Run the server: python app.py 
The server will run on localhost 
To access the server. The desktop and Mobile devices both should be on one wifi. 
After Running the server You can see the URL where server is running. Just put that URL into \lib\socket_services.dart at the palace of http://10.240.0.166:5000. 

2. Connect an Mobile device by USB or throw wifi connection 

First Unable the USB degugging on your mobile device. 
If you are running on adroid device then you should have Android-studio installed. 
to connect the mobile to desktop: adb connect "Your_Mobile_IP_Address_Port" 
example: adb connect 10.240.2.105:4398 




USB Connection:
Enable USB debugging on your mobile device.
Ensure you have Android Studio installed if you are using an Android device.
Connect your mobile device to the desktop using the following command, replacing "Your_Mobile_IP_Address_Port" with your actual mobile IP address and port:

adb connect "Your_Mobile_IP_Address_Port"
Example: adb connect 10.240.2.105:4398
Wi-Fi Connection:
Ensure both the desktop and mobile device are connected to the same Wi-Fi network.
Follow the same steps as above to enable USB debugging and connect the devices using adb.

## Running the Application

**1. Start the Server:**

- Navigate to your project directory and run `python app.py` in your terminal.
- Note the server URL displayed in the console (usually `localhost:port_number`).

**2. Update Mobile Configuration:**

- update the connection details in your mobile app's `lib/socket_services.dart` to reflect the actual server URL.

**3. Connect Your Mobile Device:**

**- USB:**
    - Enable USB debugging and Wireless debugging on your device and connect it to your computer using a USB cable.
    - For wireless Connection on Android devices with Android Studio, use `adb connect "Your_Mobile_IP_Address_Port"` (replace placeholder with your device's IP and port).

**- Wi-Fi:**
    - Ensure both devices are on the same Wi-Fi network to access the server APIs.

**4. To Run Flutter Application:**
    - `flutter run dev` or In VSCode click on Run and then Start debugging (F5)

**Additional Notes:**

- Double-check network and firewall settings if connection issues arise.


